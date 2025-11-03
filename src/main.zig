const std = @import("std");
const glfw_vulkan_template = @import("glfw_vulkan_template");
const glfw = @import("zglfw");
const vk = @import("vulkan");

const WIDTH: u16 = 800;
const HEIGHT: u16 = 600;
var window: *glfw.Window = undefined;

pub fn main() u8 {
    run() catch return 1;

    return 0;
}

fn run() !void {
    try initWindow();
    initVulkan();
    mainLoop();
    cleanup();
}

fn initWindow() !void {
    try glfw.init();

    std.debug.print("Initialized GLFW\n", .{});

    glfw.windowHint(glfw.WindowHint.client_api, glfw.ClientApi.no_api);
    glfw.windowHint(glfw.WindowHint.resizable, false);
    window = try glfw.createWindow(WIDTH, HEIGHT, "Vulkan", null);
    defer glfw.destroyWindow(window);

    while (!window.shouldClose(window)) {
        glfw.pollEvents();

        // render your things here

        window.swapBuffers();
    }
}
fn initVulkan() void {}

fn mainLoop() void {}

fn cleanup() void {
    glfw.destroyWindow(window);
    glfw.terminate();
}
