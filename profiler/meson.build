project('Tracy', 'c', 'cpp', default_options: ['cpp_std=c++20'])

fs = import('fs')
os = host_machine.system()

profiler_files = [
    'src/imgui/imgui_impl_opengl3.cpp',
    'src/ConnectionHistory.cpp',
    'src/Filters.cpp',
    'src/Fonts.cpp',
    'src/HttpRequest.cpp',
    'src/ImGuiContext.cpp',
    'src/ini.c',
    'src/IsElevated.cpp',
    'src/main.cpp',
    'src/ResolvService.cpp',
    'src/RunQueue.cpp',
    'src/WindowPosition.cpp',
    'src/winmain.cpp',
    'src/winmainArchDiscovery.cpp',
]

compiler = meson.get_compiler('cpp')
compile_args = compiler.get_supported_arguments([
    '-march=native'
])

add_global_arguments([compile_args, '-DIMGUI_ENABLE_FREETYPE'], language: ['c', 'cpp'])

common_files = fs.read('../common/common.files').strip().split('\n')
server_files = fs.read('../common/server.files').strip().split('\n')
zstd_files = fs.read('../common/zstd.files').strip().split('\n')
if os != 'windows'
    zstd_files += fs.read('../common/zstd-asm.files').strip().split('\n')
endif

imgui_files = [
    '../imgui/misc/freetype/imgui_freetype.cpp',
    '../imgui/imgui_demo.cpp',
    '../imgui/imgui_draw.cpp',
    '../imgui/imgui_tables.cpp',
    '../imgui/imgui_widgets.cpp',
    '../imgui/imgui.cpp',
]

deps = [
    dependency('freetype2'),
    dependency('capstone'),
    dependency('tbb', required: false),
]

if os == 'windows'
    add_global_arguments([
            '-D_CRT_SECURE_NO_DEPRECATE',
            '-D_CRT_NONSTDC_NO_DEPRECATE',
            '-DWIN32_LEAN_AND_MEAN',
            '-DNOMINMAX',
            '-D_USE_MATH_DEFINES',
            '/bigobj',
        ],
        language: ['c', 'cpp']
    )
    deps += [
        compiler.find_library('ws2_32'),
    ]
endif

nfd_files = []

if get_option('no-fileselector')
    add_global_arguments('-DTRACY_NO_FILESELECTOR', language: ['c', 'cpp'])
else
    if os == 'darwin'
        add_languages('objc')
        nfd_files += [
            '../nfd/nfd_cocoa.m',
        ]
    elif os == 'linux' and not get_option('gtk-fileselector')
        nfd_files += [
            '../nfd/nfd_portal.cpp',
        ]
        deps += [
            dependency('dbus-1')
        ]
    elif os == 'windows'
        nfd_files += [
            '../nfd/nfd_win.cpp',
        ]
    else
        nfd_files += [
            '../nfd/nfd_gtk.cpp',
        ]
        deps += [
            dependency('gtk+-3.0'),
        ]
    endif
endif


files = [
    common_files,
    server_files,
    zstd_files,
    imgui_files,
    nfd_files,
    profiler_files
]

if os != 'linux' or get_option('legacy')
    files += [
        'src/BackendGlfw.cpp',
        'src/imgui/imgui_impl_glfw.cpp',
    ]
    deps += [
        dependency('glfw3'),
    ]
else
    wl_proto = dependency('wayland-protocols')
    wl_scanner = dependency('wayland-scanner')

    wl_proto_dir = wl_proto.get_variable('pkgdatadir')
    wl_scanner_bin = find_program(wl_scanner.get_variable('wayland_scanner'))

    protocols = {
        'xdg-shell': wl_proto_dir / 'stable/xdg-shell/xdg-shell.xml',
        'xdg-decoration': wl_proto_dir / 'unstable/xdg-decoration/xdg-decoration-unstable-v1.xml',
        'xdg-activation': wl_proto_dir / 'staging/xdg-activation/xdg-activation-v1.xml',
    }

    foreach name, path : protocols
        code = custom_target(
            name.underscorify() + '_c',
            input: path,
            output: '@BASENAME@-protocol.c',
            command: [wl_scanner_bin, 'private-code', '@INPUT@', '@OUTPUT@']
        )
        files += code

        header = custom_target(
            name.underscorify() + '_client_h',
            input: path,
            output: '@BASENAME@.h',
            command: [wl_scanner_bin, 'client-header', '@INPUT@', '@OUTPUT@']
        )
        files += header
    endforeach

    files += [
        'src/BackendWayland.cpp',
    ]
    deps += [
        dependency('egl'),
        dependency('wayland-egl'),
        dependency('wayland-cursor'),
        dependency('xkbcommon'),
    ]
endif

inc = [
    include_directories('../imgui'),
]

executable('tracy-profiler', files, dependencies: deps, include_directories: inc)
