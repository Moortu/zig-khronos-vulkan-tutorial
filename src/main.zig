const std = @import("std");
const glfw = @import("zglfw");
const vk = @import("vulkan");

const WIDTH: u32 = 800;
const HEIGHT: u32 = 600;

const apis: []const vk.ApiInfo = &.{
    .{
        .base_commands = .{
            .createInstance = true,
            .enumerateInstanceLayerProperties = true,
            .enumerateInstanceExtensionProperties = true,
        },
    },
};

const BaseDispatch = vk.BaseWrapper(apis);
const InstanceDispatch = vk.InstanceWrapper(apis);

const Instance = vk.InstanceProxy(apis);

// Declare the C function directly with Vulkan types as per vulkan-zig documentation
// vk.Instance and vk.PfnVoidFunction are ABI compatible with VkInstance
// Needed because the zglfw library does not export the function pointer with vulkan-zig compatible types
pub extern fn glfwGetInstanceProcAddress(instance: vk.Instance, procname: [*:0]const u8) vk.PfnVoidFunction;

pub fn main() !void {
    var app = TriangleApplication.init();
    defer app.cleanup();
    try app.run();
}

const TriangleApplication = struct {
    const Self = @This();
    window: ?*glfw.Window = null,
    vkb: vk.BaseWrapper = undefined,

    pub fn init() Self {
        return Self{};
    }

    pub fn run(self: *Self) !void {
        try self.initWindow();
        try self.initVulkan();
        self.mainLoop();
    }

    fn initWindow(self: *Self) !void {
        try glfw.init();
        self.vkb = vk.BaseWrapper.load(glfwGetInstanceProcAddress);

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
    fn initVulkan(self: *Self) !void {
        const allocator = std.heap.c_allocator;

        // 1. Get required extensions from GLFW
        const req_extensions = try glfw.getRequiredInstanceExtensions();

        // 2. Query how many instance extensions Vulkan supports
        var property_count: u32 = 0;
        _ = try self.vkb.enumerateInstanceExtensionProperties(null, &property_count, null);

        // 3. Allocate buffer for extension properties
        var props = try allocator.alloc(vk.ExtensionProperties, property_count);
        defer allocator.free(props);

        // 4. Fill extension properties
        _ = try self.vkb.enumerateInstanceExtensionProperties(null, &property_count, props.ptr);

        // 5. Check that every GLFW-required extension is supported
        for (req_extensions) |ext_cstr| {
            if (!hasExtension(ext_cstr, props[0..property_count])) {
                std.debug.print(
                    "Required GLFW extension not supported: {s}\n",
                    .{ext_cstr},
                );
                return error.MissingRequiredExtension;
            }
        }

        const createInfo = vk.InstanceCreateInfo{
            .p_application_info = &vk.ApplicationInfo{
                .p_application_name = "Hello Triangle",
                .application_version = @bitCast(vk.makeApiVersion(1, 0, 0, 0)),
                .p_engine_name = "No Engine",
                .engine_version = @bitCast(vk.makeApiVersion(1, 0, 0, 0)),
                .api_version = @bitCast(vk.API_VERSION_1_4),
            },
        };
        _ = try self.vkb.createInstance(&createInfo, null);
    }

    fn hasExtension(name: [*:0]const u8, props: []const vk.ExtensionProperties) bool {
        const target = std.mem.sliceTo(name, 0);
        for (props) |p| {
            const prop_name = std.mem.sliceTo(&p.extension_name, 0);
            if (std.mem.eql(u8, prop_name, target)) return true;
        }
        return false;
    }

    fn mainLoop(_: *Self) void {}

    fn cleanup(self: *Self) void {
        if (self.window) |win| {
            win.destroy();
            self.window = null;
        }
        glfw.terminate();
    }
};
