const std = @import("std");
const glfw = @import("zglfw");
const vk = @import("vulkan");

const WIDTH: u16 = 800;
const HEIGHT: u16 = 600;

pub fn main() u8 {
    var app = TriangleApplication.init();
    defer app.cleanup();
    try app.run() catch return 1;

    return 0;
}

const TriangleApplication = struct {
    const Self = @This();
    window: ?glfw.Window = null,

    pub fn init() Self {
        return Self{};
    }

    pub fn run(self: *Self) !void {
        try self.initWindow();
        self.initVulkan();
        self.mainLoop();
    }

    fn initWindow(self: *Self) !void {
        try glfw.init(.{});

        std.debug.print("Initialized GLFW\n", .{});

        self.window = try glfw.createWindow(WIDTH, HEIGHT, "Vulkan", null, null, .{
            .client_api = .no_api,
            .resizable = false,
        });

        while (!self.window.shouldClose(self.window)) {
            glfw.pollEvents();

            // render your things here

            self.window.swapBuffers();
        }
    }
    fn initVulkan(_: *Self) void {}

    fn mainLoop(_: *Self) void {}

    fn cleanup(self: *Self) void {
        if (self.window != null) self.window.?.destroy();
        glfw.terminate();
    }
};
