install-dependencies:
	sudo apt install -y libglfw3-dev libgl1-mesa-dev libvulkan-dev

debug-run:
	zig build run -Doptimize=Debug --prefix build/debug

release-run:
	zig build -Doptimize=ReleaseSmall --prefix build/release