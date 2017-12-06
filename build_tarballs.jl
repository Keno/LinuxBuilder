using BinaryBuilder

# These are the platforms built inside the wizard
platforms = [
    BinaryProvider.Linux(:x86_64, :glibc)
]


# If the user passed in a platform (or a few, comma-separated) on the
# command-line, use that instead of our default platforms
if length(ARGS) > 0
    platforms = platform_key.(split(ARGS[1], ","))
end
info("Building for $(join(triplet.(platforms), ", "))")

# Collection of sources required to build linux
sources = [
    "https://github.com/torvalds/linux/archive/v4.15-rc2.tar.gz" =>
    "98d1d188424d280a3e07b3dbff589422e44124145f7ed2003f38c81be57ce9c4",
]

script = raw"""
cd $WORKSPACE/srcdir
export PATH=/usr/bin:$PATH
cd linux-4.15-rc2/
curl -OL https://raw.githubusercontent.com/JuliaPackaging/BinaryBuilder.jl/e6ac598dc48023f57f470d2a2fb6d10d450dbced/deps/linuxkernel.config
cp linuxkernel.config arch/x86/configs/binarybuilder_defconfig
apk add libelf-dev openssl-dev libelf-dev gcc linux-headers musl-dev bc
make binarybuilder_defconfig
make -j40
cp vmlinux $DESTDIR
cp arch/x86/boot/bzImage $DESTDIR

"""

products = prefix -> [
    ExecutableProduct(prefix,"vmlinux")
]

# Build the given platforms using the given sources
autobuild(pwd(), "linux", platforms, sources, script, products)

