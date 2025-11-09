const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const vulkan = b.dependency("vulkan_zig", .{
        .registry = b.dependency("vulkan_headers", .{}).path("registry/vk.xml"),
    }).module("vulkan-zig");

    const zglfw = b.dependency("zglfw", .{
        .target = target,
        .optimize = optimize,
    });

    const zgui = b.dependency("zgui", .{
        .target = target,
        .optimize = optimize,
        .shared = false,
        .with_implot = true,
    });

    const exe = b.addExecutable(.{
        .name = "glfw_vulkan_template",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    exe.root_module.addImport("vulkan", vulkan);
    exe.root_module.addImport("zgui", zgui.module("root"));
    exe.root_module.addImport("zglfw", zglfw.module("root"));

    // Link the compiled GLFW library from glfw_zig so zglfw's extern declarations resolve
    if (target.result.os.tag != .emscripten) {
        exe.linkLibrary(zglfw.artifact("glfw"));
    }
    exe.linkLibrary(zgui.artifact("imgui"));

    b.installArtifact(exe);

    const run_step = b.step("run", "Run the app");

    const run_cmd = b.addRunArtifact(exe);
    run_step.dependOn(&run_cmd.step);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const exe_tests = b.addTest(.{
        .root_module = exe.root_module,
    });

    const run_exe_tests = b.addRunArtifact(exe_tests);

    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_exe_tests.step);
}
