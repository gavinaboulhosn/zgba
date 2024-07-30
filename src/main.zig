const std = @import("std");

pub const Memory = struct {
    pub fn init() Memory {
        return Memory{};
    }

    pub fn read(self: *Memory, address: u16) u8 {
        _ = address;
        _ = self;
        return 0;
    }

    pub fn write(self: *Memory, address: u16, value: u8) void {
        _ = address;
        _ = value;
        _ = self;
    }
};

pub const CPU = struct {
    const Self = @This();

    // Registers
    af: u16 = 0,
    bc: u16 = 0,
    de: u16 = 0,
    hl: u16 = 0,
    sp: u16 = 0,
    pc: u16 = 0,

    memory: *Memory,

    // Flags
    flags: Flags = .{},

    const Flags = packed struct {
        c: bool = false,
        h: bool = false,
        n: bool = false,
        z: bool = false,
        _unused: u4 = 0,
    };

    const FlagIndex = enum {
        c,
        h,
        n,
        z,
    };

    pub fn init(memory: *Memory) Self {
        return .{
            .memory = memory,
        };
    }

    pub fn read8(self: *Self, address: u16) u8 {
        return self.memory.read(address);
    }

    pub fn write8(self: *Self, address: u16, value: u8) void {
        self.memory.write(address, value);
    }

    pub fn read16(self: *Self, address: u16) u16 {
        const low = self.read8(address);
        const high = self.read8(address + 1);
        return @as(u16, low) | (@as(u16, high) << 8);
    }

    pub fn write16(self: *Self, address: u16, value: u16) void {
        const low: u8 = @truncate(value);
        const high: u8 = @truncate(value >> 8);
        self.write8(address, low);
        self.write8(address + 1, high);
    }

    pub fn getFlag(self: *Self, flag: FlagIndex) bool {
        return @field(self.flags, @tagName(flag));
    }

    pub fn setFlag(self: *Self, flag: FlagIndex, value: bool) void {
        @field(self.flags, @tagName(flag)) = value;
    }

    pub fn exec(self: *Self) void {
        const opcode = self.read8(self.pc);
        switch (opcode) {
            0x00 => {
                // NOP
                self.pc += 1;
            },
            else => {
                std.debug.print("Unhandled opcode: 0x{X:0>2}\n", .{opcode});
                @panic("Unhandled opcode");
            },
        }
    }
};

pub fn main() !void {
    var memory = Memory.init();
    var cpu = CPU.init(&memory);

    while (true) {
        cpu.exec();
    }
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
