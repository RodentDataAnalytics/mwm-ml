function draw_ellipse(xc, yc, a, b, inc, style)
%DRAW_ELLIPSE draws an elipse with center in (xc,yc), semiaxes (a, b) and rotation (inc) in radians.
    t = linspace(0,2*pi);
    px = a*cos(t);
    py = b*sin(t);
    inc = inc;
    x = xc + px*cos(inc) - py*sin(inc);
    y = yc + px*sin(inc) + py*cos(inc);
    plot(x, y, '-r'); % '-r' can be replaced with 'style' for manually configuration of linestyle
end
