// Small square for list rows and plan cards. A fixed format means
// Cloudinary keeps one cached copy per size
const thumbTransform = 'w_160,h_160,c_fill,f_webp,q_auto';

// Wide still for the detail page, about phone width at 2x
const detailTransform = 'w_800,f_webp,q_auto';

// A sized Cloudinary URL built from the stored original
String sizedImageUrl(String url, String transform) =>
    url.replaceFirst('/upload/', '/upload/$transform/');
