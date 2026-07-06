
# projection tester

This repo was created to generate maps based on custom map projections.
Currently only hemispheric projections are implemented, but changing this is
pretty easy -- the whole repo is a few hundred lines. stereographic.lua gives a
hemispheric stereographic projection, and mollweide.lua gives a Mollweide
projection. To satisfy my own curiosity, I also included a projection which is
the polar-coordinate average of stereographic and Mollweide. 

Examples:

![Mollweide projection](https://i.postimg.cc/JH3sq0g2/moll.png)

![(Mollweide + stereographic) / 2 projection](https://i.postimg.cc/XBKr8qhm/ms.png)

![Stereographic projection](https://i.postimg.cc/FkbYZzqD/ster.png)

## Credits

The map data used in this project is from Natural Earth:

https://naturalearthdata.com/

https://github.com/nvkelso/natural-earth-vector

