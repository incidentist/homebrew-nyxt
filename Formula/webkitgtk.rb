class Webkitgtk < Formula
  desc "Full-featured Gtk+ port of the WebKit rendering engine"
  homepage "http://webkitgtk.org"
  url "http://webkitgtk.org/releases/webkitgtk-2.34.3.tar.xz"
  sha256 "0d2f37aa32e21a36e4dd5a5ce7ae5ce27435c29d6803b962b8c90cb0cc49c52d"

  depends_on "cmake" => :build
  depends_on "ninja" => :build
  depends_on "enchant"
  depends_on "gtk+3"
  depends_on "libgcrypt"
  depends_on "libsoup"
  depends_on "webp"

  patch :DATA

  def install
    extra_args = %w[
      -GNinja
      -DPORT=GTK
      -DENABLE_X11_TARGET=OFF
      -DENABLE_WAYLAND_TARGET=OFF
      -DENABLE_QUARTZ_TARGET=ON
      -DENABLE_TOOLS=ON
      -DENABLE_MINIBROWSER=OFF
      -DENABLE_PLUGIN_PROCESS_GTK2=OFF
      -DENABLE_VIDEO=OFF
      -DENABLE_WEB_AUDIO=OFF
      -DENABLE_GEOLOCATION=OFF
      -DENABLE_OPENGL=OFF
      -DUSE_LIBNOTIFY=OFF
      -DUSE_LIBHYPHEN=OFF
      -DENABLE_GAMEPAD=OFF
      -DUSE_SYSTEMD=OFF
      -DUSE_APPLE_ICU=OFF
    ]

    system "cmake", ".", *(std_cmake_args + extra_args)
    system "cmake", "--build", "."
    system "cmake", "--build", ".", "--", "install"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <webkit2/webkit2.h>

      int main(int argc, char *argv[]) {
        fprintf(stdout, "%d.%d.%d\\n",
          webkit_get_major_version(),
          webkit_get_minor_version(),
          webkit_get_micro_version());
        return 0;
      }
    EOS
    ENV.libxml2
    atk = Formula["atk"]
    cairo = Formula["cairo"]
    fontconfig = Formula["fontconfig"]
    freetype = Formula["freetype"]
    gdk_pixbuf = Formula["gdk-pixbuf"]
    gettext = Formula["gettext"]
    glib = Formula["glib"]
    gtkx3 = Formula["gtk+3"]
    harfbuzz = Formula["harfbuzz"]
    libepoxy = Formula["libepoxy"]
    libpng = Formula["libpng"]
    libsoup = Formula["libsoup"]
    pango = Formula["pango"]
    pixman = Formula["pixman"]
    flags = (ENV.cflags || "").split + (ENV.cppflags || "").split + (ENV.ldflags || "").split
    flags += %W[
      -I#{atk.opt_include}/atk-1.0
      -I#{cairo.opt_include}/cairo
      -I#{fontconfig.opt_include}
      -I#{freetype.opt_include}/freetype2
      -I#{gdk_pixbuf.opt_include}/gdk-pixbuf-2.0
      -I#{gettext.opt_include}
      -I#{glib.opt_include}/gio-unix-2.0/
      -I#{glib.opt_include}/glib-2.0
      -I#{glib.opt_lib}/glib-2.0/include
      -I#{gtkx3.opt_include}/gtk-3.0
      -I#{harfbuzz.opt_include}/harfbuzz
      -I#{include}/webkitgtk-4.0
      -I#{libepoxy.opt_include}
      -I#{libpng.opt_include}/libpng16
      -I#{libsoup.opt_include}/libsoup-2.4
      -I#{pango.opt_include}/pango-1.0
      -I#{pixman.opt_include}/pixman-1
      -D_REENTRANT
      -L#{atk.opt_lib}
      -L#{cairo.opt_lib}
      -L#{gdk_pixbuf.opt_lib}
      -L#{gettext.opt_lib}
      -L#{glib.opt_lib}
      -L#{gtkx3.opt_lib}
      -L#{libsoup.opt_lib}
      -L#{lib}
      -L#{pango.opt_lib}
      -latk-1.0
      -lcairo
      -lcairo-gobject
      -lgdk-3
      -lgdk_pixbuf-2.0
      -lgio-2.0
      -lglib-2.0
      -lgobject-2.0
      -lgtk-3
      -lintl
      -ljavascriptcoregtk-4.0
      -lpango-1.0
      -lpangocairo-1.0
      -lsoup-2.4
      -lwebkit2gtk-4.0
    ]
    system ENV.cc, "test.c", "-o", "test", *flags
    assert_match version.to_s, shell_output("./test")
  end
end

# These patches are taken from the Nix package definition: https://github.com/NixOS/nixpkgs/blob/master/pkgs/development/libraries/webkitgtk/default.nix
# We can't use the raw patches because they include hunks for changelog files
# that are not present in the tarball.
__END__
diff -aru a/Source/WebKit/NetworkProcess/ServiceWorker/WebSWOriginStore.cpp b/Source/WebKit/NetworkProcess/ServiceWorker/WebSWOriginStore.cpp
--- a/Source/WebKit/NetworkProcess/ServiceWorker/WebSWOriginStore.cpp	2021-02-26 04:57:15.000000000 -0500
+++ b/Source/WebKit/NetworkProcess/ServiceWorker/WebSWOriginStore.cpp	2021-05-16 14:45:32.000000000 -0400
@@ -87,7 +87,7 @@
     if (!m_store.createSharedMemoryHandle(handle))
         return;
 
-#if OS(DARWIN) || OS(WINDOWS)
+#if (OS(DARWIN) || OS(WINDOWS)) && !USE(UNIX_DOMAIN_SOCKETS)
     uint64_t dataSize = handle.size();
 #else
     uint64_t dataSize = 0;
diff -aru a/Source/WebKit/Platform/IPC/IPCSemaphore.cpp b/Source/WebKit/Platform/IPC/IPCSemaphore.cpp
--- a/Source/WebKit/Platform/IPC/IPCSemaphore.cpp	2021-02-26 04:57:15.000000000 -0500
+++ b/Source/WebKit/Platform/IPC/IPCSemaphore.cpp	2021-05-16 15:54:53.000000000 -0400
@@ -26,8 +26,6 @@
 #include "config.h"
 #include "IPCSemaphore.h"
 
-#if !OS(DARWIN)
-
 namespace IPC {
 
 Semaphore::Semaphore() = default;
@@ -46,5 +44,3 @@
 }
 
 }
-
-#endif
diff -aru a/Source/WebKit/Platform/IPC/IPCSemaphore.h b/Source/WebKit/Platform/IPC/IPCSemaphore.h
--- a/Source/WebKit/Platform/IPC/IPCSemaphore.h	2021-02-26 04:57:15.000000000 -0500
+++ b/Source/WebKit/Platform/IPC/IPCSemaphore.h	2021-05-16 14:46:13.000000000 -0400
@@ -29,7 +29,7 @@
 #include <wtf/Optional.h>
 #include <wtf/Seconds.h>
 
-#if OS(DARWIN)
+#if PLATFORM(COCOA)
 #include <mach/semaphore.h>
 #include <wtf/MachSendRight.h>
 #endif
@@ -51,7 +51,7 @@
     void encode(Encoder&) const;
     static Optional<Semaphore> decode(Decoder&);
 
-#if OS(DARWIN)
+#if PLATFORM(COCOA)
     explicit Semaphore(MachSendRight&&);
 
     void signal();
@@ -64,7 +64,7 @@
 #endif
 
 private:
-#if OS(DARWIN)
+#if PLATFORM(COCOA)
     void destroy();
     MachSendRight m_sendRight;
     semaphore_t m_semaphore { SEMAPHORE_NULL };
Only in b/Source/WebKit/Platform/IPC: IPCSemaphore.h.orig
diff -aru a/Source/WebKit/Platform/SharedMemory.h b/Source/WebKit/Platform/SharedMemory.h
--- a/Source/WebKit/Platform/SharedMemory.h	2021-02-26 04:57:15.000000000 -0500
+++ b/Source/WebKit/Platform/SharedMemory.h	2021-05-16 14:45:32.000000000 -0400
@@ -75,7 +75,7 @@
 
         bool isNull() const;
 
-#if OS(DARWIN) || OS(WINDOWS)
+#if (OS(DARWIN) || OS(WINDOWS)) && !USE(UNIX_DOMAIN_SOCKETS)
         size_t size() const { return m_size; }
 #endif
 
diff -aru a/Source/WebKit/UIProcess/VisitedLinkStore.cpp b/Source/WebKit/UIProcess/VisitedLinkStore.cpp
--- a/Source/WebKit/UIProcess/VisitedLinkStore.cpp	2021-02-26 04:57:16.000000000 -0500
+++ b/Source/WebKit/UIProcess/VisitedLinkStore.cpp	2021-05-16 14:45:32.000000000 -0400
@@ -119,7 +119,7 @@
         return;
 
     // FIXME: Get the actual size of data being sent from m_linkHashStore and send it in the SharedMemory::IPCHandle object.
-#if OS(DARWIN) || OS(WINDOWS)
+#if (OS(DARWIN) || OS(WINDOWS)) && !USE(UNIX_DOMAIN_SOCKETS)
     uint64_t dataSize = handle.size();
 #else
     uint64_t dataSize = 0;
Only in b/Source/WebKit/WebProcess/WebPage/CoordinatedGraphics: DrawingAreaCoordinatedGraphics.cpp.orig

# audit_token_t patch from https://bug-225850-attachments.webkit.org/attachment.
diff --git a/Source/WTF/wtf/PlatformHave.h b/Source/WTF/wtf/PlatformHave.h
index 0e140926fe40..4f53b92280b7 100644
--- a/Source/WTF/wtf/PlatformHave.h
+++ b/Source/WTF/wtf/PlatformHave.h
@@ -52,6 +52,10 @@
 #define HAVE_ARM_IDIV_INSTRUCTIONS 1
 #endif
 
+#if PLATFORM(COCOA)
+#define HAVE_AUDIT_TOKEN 1
+#endif
+
 #if PLATFORM(COCOA)
 #define HAVE_OUT_OF_PROCESS_LAYER_HOSTING 1
 #endif
@@ -190,10 +194,6 @@
 #define HAVE_SYS_TIMEB_H 1
 #endif
 
-#if OS(DARWIN)
-#define HAVE_AUDIT_TOKEN 1
-#endif
-
 #if OS(DARWIN) && __has_include(<mach/mach_exc.defs>) && !PLATFORM(GTK)
 #define HAVE_MACH_EXCEPTIONS 1
 #endif

# forceRepaintAsync issue: https://bugs.webkit.org/show_bug.cgi?id=224149
diff --git a/Source/WebKit/WebProcess/WebPage/CoordinatedGraphics/LayerTreeHost.h b/Source/WebKit/WebProcess/WebPage/CoordinatedGraphics/LayerTreeHost.h
index 6727d16c8c0b..db65f813267d 100644
--- a/Source/WebKit/WebProcess/WebPage/CoordinatedGraphics/LayerTreeHost.h
+++ b/Source/WebKit/WebProcess/WebPage/CoordinatedGraphics/LayerTreeHost.h
@@ -213,7 +213,7 @@ inline void LayerTreeHost::setRootCompositingLayer(WebCore::GraphicsLayer*) { }
 inline void LayerTreeHost::setViewOverlayRootLayer(WebCore::GraphicsLayer*) { }
 inline void LayerTreeHost::scrollNonCompositedContents(const WebCore::IntRect&) { }
 inline void LayerTreeHost::forceRepaint() { }
-inline bool LayerTreeHost::forceRepaintAsync(CompletionHandler<void()>&) { return false; }
+inline void LayerTreeHost::forceRepaintAsync(CompletionHandler<void()>&&) { }
 inline void LayerTreeHost::sizeDidChange(const WebCore::IntSize&) { }
 inline void LayerTreeHost::pauseRendering() { }
 inline void LayerTreeHost::resumeRendering() { }

# ambiguous abs usage: https://bugs.webkit.org/show_bug.cgi?id=225856
diff --git a/Source/WebCore/platform/graphics/ColorComponents.h b/Source/WebCore/platform/graphics/ColorComponents.h
index 1834c028ead5..e17d004f5e1a 100644
--- a/Source/WebCore/platform/graphics/ColorComponents.h
+++ b/Source/WebCore/platform/graphics/ColorComponents.h
@@ -27,7 +27,7 @@
 
 #include <algorithm>
 #include <array>
-#include <math.h>
+#include <cmath>
 #include <tuple>
 
 namespace WebCore {