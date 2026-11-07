/*
 * edgewarp: moves the pointer over a monitor edge to the same relative height
 * on the other side. X itself moves the pointer 1:1 and stops it where the
 * neighbour is shorter, e.g. at the bottom of a big screen in the middle.
 *
 * Every vertical edge shared by two monitors gets a pointer barrier. The X
 * server reports when the pointer pushes against one, and only then edgewarp
 * warps it. Nothing runs on plain pointer motion. RandR changes rebuild the
 * barriers.
 *
 * Run by edgewarp.service in the X session. -v prints the barriers and warps.
 */
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <X11/Xlib.h>
#include <X11/extensions/XInput2.h>
#include <X11/extensions/Xfixes.h>
#include <X11/extensions/Xrandr.h>

#define MAXEDGES 64

typedef struct {
	int x, y, w, h;
} Rect;

/* a vertical edge shared by two monitors */
typedef struct {
	PointerBarrier barrier;
	Rect left, right;
	int x; /* first column of right */
} Edge;

static Display *dpy;
static Window root;
static Edge edges[MAXEDGES];
static int nedges;
static int verbose;

static void
die(const char *fmt, ...)
{
	va_list ap;

	va_start(ap, fmt);
	fputs("edgewarp: ", stderr);
	vfprintf(stderr, fmt, ap);
	fputc('\n', stderr);
	va_end(ap);
	exit(1);
}

static void
addedge(Rect left, Rect right)
{
	Edge *e;
	int y1, y2;

	if (nedges == MAXEDGES)
		return;
	e = &edges[nedges++];
	e->left = left;
	e->right = right;
	e->x = right.x;
	/* The barrier covers both sides, so the dead part next to the shorter
	 * monitor is included. It blocks both directions: two one-way barriers on
	 * the same line do not work. The server picks either of them for a
	 * diagonal motion, and the one that lets it through does not clamp. */
	y1 = left.y < right.y ? left.y : right.y;
	y2 = left.y + left.h > right.y + right.h ?
	    left.y + left.h : right.y + right.h;
	e->barrier = XFixesCreatePointerBarrier(dpy, root, e->x, y1, e->x, y2,
	    0, 0, NULL);
	if (verbose)
		fprintf(stderr, "edgewarp: barrier at x=%d, y=%d..%d\n",
		    e->x, y1, y2 - 1);
}

static void
setup(void)
{
	XRRMonitorInfo *m;
	Rect a, b;
	int i, j, n;

	for (i = 0; i < nedges; i++)
		XFixesDestroyPointerBarrier(dpy, edges[i].barrier);
	nedges = 0;

	if (!(m = XRRGetMonitors(dpy, root, True, &n)))
		return;
	for (i = 0; i < n; i++) {
		for (j = 0; j < n; j++) {
			a = (Rect){ m[i].x, m[i].y, m[i].width, m[i].height };
			b = (Rect){ m[j].x, m[j].y, m[j].width, m[j].height };
			/* a is directly left of b, and they share part of the edge */
			if (a.x + a.w != b.x || a.y >= b.y + b.h || b.y >= a.y + a.h)
				continue;
			addedge(a, b);
		}
	}
	XRRFreeMonitors(m);
}

static void
warp(XIBarrierEvent *ev)
{
	XIButtonState buttons;
	XIModifierState mods;
	XIGroupState group;
	Window r, child;
	Edge *e;
	Rect *from, *to;
	double px, py, wx, wy, rel;
	int i, x, y;

	for (i = 0; i < nedges && edges[i].barrier != ev->barrier; i++)
		;
	if (i == nedges || ev->dx == 0)
		return;
	e = &edges[i];
	from = ev->dx > 0 ? &e->left : &e->right;
	to = ev->dx > 0 ? &e->right : &e->left;

	/* The server reports a hit for every motion against the barrier, so
	 * hits queue up while the first warp is on its way. Only a pointer that
	 * still sits at the barrier, on the side it leaves, is warped. */
	if (!XIQueryPointer(dpy, ev->deviceid, root, &r, &child, &px, &py,
	    &wx, &wy, &buttons, &mods, &group))
		return;
	free(buttons.mask);
	if ((int)px != (ev->dx > 0 ? e->x - 1 : e->x) ||
	    py < from->y || py >= from->y + from->h) {
		if (verbose)
			fprintf(stderr, "edgewarp: stale hit at %.0f,%.0f\n", px, py);
		return;
	}

	/* top row to top row, bottom row to bottom row */
	rel = from->h > 1 ? (py - from->y) / (from->h - 1) : 0;
	y = to->y + (int)(rel * (to->h - 1) + 0.5);
	if (y < to->y)
		y = to->y;
	if (y > to->y + to->h - 1)
		y = to->y + to->h - 1;
	/* the blocked motion goes on behind the edge */
	x = (ev->dx > 0 ? e->x : e->x - 1) + (int)ev->dx;
	if (x < to->x)
		x = to->x;
	if (x > to->x + to->w - 1)
		x = to->x + to->w - 1;

	if (verbose)
		fprintf(stderr, "edgewarp: %.0f,%.0f -> %d,%d (dx %.0f)\n",
		    px, py, x, y, ev->dx);
	XIWarpPointer(dpy, ev->deviceid, None, root, 0, 0, 0, 0, x, y);
	XFlush(dpy);
}

int
main(int argc, char *argv[])
{
	unsigned char mask[XIMaskLen(XI_LASTEVENT)] = { 0 };
	XIEventMask em;
	XEvent ev;
	int xi, rr, evbase, errbase, major, minor;

	if (argc == 2 && !strcmp(argv[1], "-v"))
		verbose = 1;
	else if (argc != 1)
		die("usage: edgewarp [-v]");
	if (!(dpy = XOpenDisplay(NULL)))
		die("cannot open display");
	root = DefaultRootWindow(dpy);

	major = 2, minor = 3;
	if (!XQueryExtension(dpy, "XInputExtension", &xi, &evbase, &errbase) ||
	    XIQueryVersion(dpy, &major, &minor) != Success ||
	    major * 100 + minor < 203)
		die("XInput 2.3 is missing");
	if (!XFixesQueryExtension(dpy, &evbase, &errbase) ||
	    !XFixesQueryVersion(dpy, &major, &minor) || major < 5)
		die("XFixes 5 is missing");
	if (!XRRQueryExtension(dpy, &rr, &errbase) ||
	    !XRRQueryVersion(dpy, &major, &minor) ||
	    major * 100 + minor < 105)
		die("RandR 1.5 is missing");

	XISetMask(mask, XI_BarrierHit);
	em.deviceid = XIAllMasterDevices;
	em.mask_len = sizeof(mask);
	em.mask = mask;
	XISelectEvents(dpy, root, &em, 1);
	XRRSelectInput(dpy, root, RRScreenChangeNotifyMask | RRCrtcChangeNotifyMask);
	setup();

	for (;;) {
		XNextEvent(dpy, &ev);
		if (ev.type == GenericEvent && ev.xcookie.extension == xi &&
		    XGetEventData(dpy, &ev.xcookie)) {
			if (ev.xcookie.evtype == XI_BarrierHit)
				warp(ev.xcookie.data);
			XFreeEventData(dpy, &ev.xcookie);
		} else if (ev.type == rr + RRScreenChangeNotify ||
		    ev.type == rr + RRNotify) {
			XRRUpdateConfiguration(&ev);
			setup();
		}
	}
}
