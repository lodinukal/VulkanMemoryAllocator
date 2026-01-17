const std = @import("std");

const ok_targets: []const []const u8 = &.{
    "x86_64-windows-msvc",
    "x86_64-linux-gnu",
    "aarch64-linux-gnu",
    "aarch64-macos",
    "x86_64-macos",
};

const TargetNamePair = struct {
    name: []const u8,
    target: std.Build.ResolvedTarget,
};

pub fn build(b: *std.Build) !void {
    const whitelisted = try b.allocator.alloc(TargetNamePair, ok_targets.len);
    defer b.allocator.free(whitelisted);

    for (ok_targets, whitelisted) |target_str, *res| {
        res.target = b.resolveTargetQuery(try std.Target.Query.parse(.{
            .arch_os_abi = target_str,
        }));
        res.name = try std.mem.replaceOwned(u8, b.allocator, target_str, "-", "_");
    }

    const optimize: std.builtin.OptimizeMode = .ReleaseSafe;

    const vulkan_headers = b.dependency("vulkan_headers", .{});
    for (whitelisted) |t| {
        const mod = b.createModule(.{
            .target = t.target,
            .optimize = optimize,
            .pic = true,
            .link_libc = true,
            .link_libcpp = t.target.result.abi != .msvc,
            .sanitize_c = .off,
        });
        mod.addCSourceFiles(.{
            .files = &.{
                "src/VmaUsage.cpp",
            },
            .flags = &.{
                "-DVMA_STATIC_VULKAN_FUNCTIONS=0",
                "-DVMA_DYNAMIC_VULKAN_FUNCTIONS=1",
            },
        });
        mod.addIncludePath(vulkan_headers.path("include"));
        mod.addIncludePath(b.path("include"));

        const lib = b.addLibrary(.{
            .name = t.name,
            .root_module = mod,
            .linkage = .static,
        });
        b.installArtifact(lib);
    }
}
