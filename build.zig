const std = @import("std");

pub fn addImGUI(source_files: *std.ArrayList([]const u8)) !void {
    try source_files.append("lib/imgui/imgui.cpp");
    try source_files.append("lib/imgui/imgui_widgets.cpp");
    try source_files.append("lib/imgui/imgui_draw.cpp");
    try source_files.append("lib/imgui/imgui_tables.cpp");
    try source_files.append("lib/imgui/backends/imgui_impl_opengl3.cpp");
    try source_files.append("lib/imgui/backends/imgui_impl_glfw.cpp");
    //try source_files.append("lib/imgui/imgui_demo.cpp");
}

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "main",
        .target = target,
        .optimize = optimize,
    });

    var main_source_files = try std.ArrayList([]const u8).initCapacity(b.allocator, 2);
    try main_source_files.append("src/main.cpp");
    try addImGUI(&main_source_files);

    exe.root_module.addCSourceFiles(.{ .files = main_source_files.items });

    exe.addIncludePath(.{ .path = "lib/imgui" });
    exe.addIncludePath(.{ .path = "lib/imgui/backends" });
    exe.linkLibCpp();
    exe.linkSystemLibrary("GLEW");
    exe.linkSystemLibrary("GL");
    exe.linkSystemLibrary("glfw");
    b.installArtifact(exe);

    // This *creates* a Run step in the build graph, to be executed when another
    // step is evaluated that depends on it. The next line below will establish
    // such a dependency.
    const run_cmd = b.addRunArtifact(exe);

    // By making the run step depend on the install step, it will be run from the
    // installation directory rather than directly from within the cache directory.
    // This is not necessary, however, if the application depends on other installed
    // files, this ensures they will be present and in the expected location.
    run_cmd.step.dependOn(b.getInstallStep());

    // This allows the user to pass arguments to the application in the build
    // command itself, like this: `zig build run -- arg1 arg2 etc`
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    // This creates a build step. It will be visible in the `zig build --help` menu,
    // and can be selected like this: `zig build run`
    // This will evaluate the `run` step rather than the default, which is "install".
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
    return;
}
