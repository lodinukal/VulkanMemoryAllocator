import vk "vendor:vulkan"

when ODIN_OS == .Windows {
    @(extra_linker_flags="/NODEFAULTLIB:libc++")
	foreign import lib { "lib/x86_64_windows_msvc.lib" }
} else when ODIN_OS == .Darwin {
	when ODIN_ARCH == .arm64 {
        foreign import lib { "lib/libaarch64_macos.a", "system:stdc++" }
    } else when ODIN_ARCH == .amd64 {
        foreign import lib { "lib/libx86_64_macos.a", "system:stdc++" }
    }
} else when ODIN_OS == .Linux {
	when ODIN_ARCH == .amd64 {
        foreign import lib { "lib/libx86_64_linux.a", "system:stdc++" }
    } else when ODIN_ARCH == .arm64 {
        foreign import lib { "lib/libaarch64_linux.a", "system:stdc++" }
    }
}