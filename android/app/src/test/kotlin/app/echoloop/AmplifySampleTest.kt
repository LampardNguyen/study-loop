package app.echoloop

import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

/** 录音增益 + 软限幅的纯函数测试。 */
class AmplifySampleTest {

    @Test
    fun smallSampleIsAmplifiedLinearly() {
        // 1000 × 2.2 = 2200，远低于拐点，线性放大（允许 1 的取整误差）。
        val out = amplifySample(1000, 2.2f)
        assertTrue(kotlin.math.abs(out - 2200) <= 1)
    }

    @Test
    fun overdrivenSampleIsCompressedNotHardClipped() {
        // 12000 × 3.5 ≈ 1.28 满幅：硬削波会直接等于最大值，软限幅应落在拐点与最大值之间。
        val out = amplifySample(12000, 3.5f)
        assertTrue(out < Short.MAX_VALUE)
        assertTrue(out > (0.8f * Short.MAX_VALUE).toInt())
        // 极端过载也不越界。
        assertTrue(amplifySample(Short.MAX_VALUE, 6f) <= Short.MAX_VALUE)
    }

    @Test
    fun negativeSampleIsSymmetric() {
        assertEquals(-amplifySample(12000, 3.5f), amplifySample(-12000, 3.5f))
    }

    @Test
    fun higherGainIsLouderButMonotonic() {
        val a = amplifySample(8000, 2.2f)
        val b = amplifySample(8000, 3.5f)
        val c = amplifySample(8000, 5f)
        assertTrue(a < b && b < c)
    }
}
