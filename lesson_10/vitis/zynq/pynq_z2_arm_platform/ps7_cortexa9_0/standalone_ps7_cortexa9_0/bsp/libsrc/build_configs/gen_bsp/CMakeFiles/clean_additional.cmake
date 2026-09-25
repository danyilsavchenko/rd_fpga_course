# Additional clean files
cmake_minimum_required(VERSION 3.16)

if("${CONFIG}" STREQUAL "" OR "${CONFIG}" STREQUAL "")
  file(REMOVE_RECURSE
  "/home/danyil/rd_fpga_course/lesson_10/vitis/zynq/pynq_z2_arm_platform/ps7_cortexa9_0/standalone_ps7_cortexa9_0/bsp/include/sleep.h"
  "/home/danyil/rd_fpga_course/lesson_10/vitis/zynq/pynq_z2_arm_platform/ps7_cortexa9_0/standalone_ps7_cortexa9_0/bsp/include/xiltimer.h"
  "/home/danyil/rd_fpga_course/lesson_10/vitis/zynq/pynq_z2_arm_platform/ps7_cortexa9_0/standalone_ps7_cortexa9_0/bsp/include/xtimer_config.h"
  "/home/danyil/rd_fpga_course/lesson_10/vitis/zynq/pynq_z2_arm_platform/ps7_cortexa9_0/standalone_ps7_cortexa9_0/bsp/lib/libxiltimer.a"
  )
endif()
