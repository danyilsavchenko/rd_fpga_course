# 2026-09-25T10:57:26.472886678
import vitis

client = vitis.create_client()
client.set_workspace(path="zynq")

platform = client.create_platform_component(name = "pynq_z2_arm_platform",hw_design = "$COMPONENT_LOCATION/../../../vivado/zynq/system_wrapper.xsa",os = "standalone",cpu = "ps7_cortexa9_0",domain_name = "standalone_ps7_cortexa9_0",compiler = "gcc")

comp = client.create_app_component(name="led_controller_arm",platform = "$COMPONENT_LOCATION/../pynq_z2_arm_platform/export/pynq_z2_arm_platform/pynq_z2_arm_platform.xpfm",domain = "standalone_ps7_cortexa9_0")

platform = client.get_component(name="pynq_z2_arm_platform")
status = platform.build()

comp = client.get_component(name="led_controller_arm")
comp.build()

