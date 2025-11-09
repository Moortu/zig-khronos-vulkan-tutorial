const std = @import("std");
const glfw = @import("zglfw");
const vk = @import("vulkan");

const WIDTH: u32 = 800;
const HEIGHT: u32 = 600;

pub fn main() u8 {
    var app = TriangleApplication.init();
    defer app.cleanup();
    app.run() catch return 1;

    return 0;
}

const TriangleApplication = struct {
    const Self = @This();
    window: ?*glfw.Window = null,

    pub fn init() Self {
        return Self{};
    }

    pub fn run(self: *Self) !void {
        try self.initWindow();
        self.initVulkan();
        self.mainLoop();
    }

    fn initWindow(self: *Self) !void {
        try glfw.init();

        std.debug.print("Initialized GLFW\n", .{});

        glfw.windowHint(glfw.WindowHint.client_api, glfw.ClientApi.no_api);
        glfw.windowHint(glfw.WindowHint.resizable, false);
        self.window = try glfw.Window.create(WIDTH, HEIGHT, "Vulkan", null);

        while (!self.window.?.shouldClose()) {
            glfw.pollEvents();

            // render your things here

            self.window.?.swapBuffers();
        }
    }
    fn initVulkan(_: *Self) void {}

    fn mainLoop(_: *Self) void {}

    fn cleanup(self: *Self) void {
        if (self.window) |win| {
            win.destroy();
            self.window = null;
        }
        glfw.terminate();
    }
};
