# 2026-09-22T22:34:30.063479164
import vitis

client = vitis.create_client()
client.set_workspace(path="microblaze")

platform = client.create_platform_component(name = "platformpynq_mb_platform",hw_design = "$COMPONENT_LOCATION/../../../vivado/microblaze/system_wrapper.xsa",os = "standalone",cpu = "microblaze_0",domain_name = "standalone_microblaze_0",compiler = "gcc")

platform = client.get_component(name="platformpynq_mb_platform")
status = platform.update_desc(desc="")

comp = client.create_app_component(name="led_controller",platform = "$COMPONENT_LOCATION/../platformpynq_mb_platform/export/platformpynq_mb_platform/platformpynq_mb_platform.xpfm",domain = "standalone_microblaze_0")

status = platform.build()

comp = client.get_component(name="led_controller")
comp.build()

status = platform.build()

comp.build()

comp.set_app_config(key = "USER_COMPILE_DEFINITIONS", values = ["SIMULATION"])

status = platform.build()

comp.build()

comp.set_app_config(key = "USER_COMPILE_DEFINITIONS", values = ["SIMULATION=1"])

status = platform.build()

comp.build()

status = platform.build()

comp.build()

