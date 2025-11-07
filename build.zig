const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    _ = b.addModule("data_structurez", .{ .root_source_file = b.path("data_structurez") });

    var main_tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/test_data_structurez.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&main_tests.step);
}
