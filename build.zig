const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.resolveTargetQuery(.{
        .cpu_arch = .aarch64,
        .os_tag = .freestanding,
    });

    const optimize = b.standardOptimizeOption(.{
        .preferred_optimize_mode = .Debug,
    });

    // platform specific modules
    const virt = b.createModule(.{
        .root_source_file = b.path("src/platform/virt/virt.zig"),
        .target = target,
        .optimize = optimize,
    });

    const kernel = b.addObject(.{
        .name = "kernel",
        .root_source_file = b.path("src/platform/init.zig"),
        .target = target,
        .optimize = optimize,
    });

    kernel.root_module.addImport("virt", virt);

    const bootloader = b.addAssembly(.{
        .name = "boot",
        .source_file = b.path("src/boot.s"),
        .target = target,
        .optimize = optimize,
    });

    const binary = b.addExecutable(.{
        .name = "zapper.bin",
        .target = target,
        .optimize = optimize,
    });

    binary.setLinkerScript(.{
        .path = "src/linker.ld",
    });

    binary.addObject(kernel);
    binary.addObject(bootloader);

    b.installArtifact(binary);
}
