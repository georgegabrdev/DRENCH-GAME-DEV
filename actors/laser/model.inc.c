Lights1 laser_red_lights = gdSPDefLights1(
	0xFF, 0x0, 0x0,
	0xFF, 0x0, 0x0, 0x28, 0x28, 0x28);

Vtx laser_000_displaylist_mesh_layer_1_vtx_0[23] = {
	{{ {0, -10, 10}, 0, {624, 1008}, {0, 129, 0, 255} }},
	{{ {0, -7, 3}, 0, {752, 752}, {0, 176, 157, 255} }},
	{{ {7, -7, 10}, 0, {496, 752}, {99, 176, 0, 255} }},
	{{ {10, 0, 10}, 0, {496, 496}, {127, 0, 0, 255} }},
	{{ {0, 0, 0}, 0, {752, 496}, {0, 0, 129, 255} }},
	{{ {-7, -7, 10}, 0, {1008, 752}, {157, 176, 0, 255} }},
	{{ {0, -10, 10}, 0, {880, 1008}, {0, 129, 0, 255} }},
	{{ {-10, 0, 10}, 0, {1008, 496}, {129, 0, 0, 255} }},
	{{ {0, 7, 3}, 0, {752, 240}, {0, 80, 157, 255} }},
	{{ {-7, 7, 10}, 0, {1008, 240}, {157, 80, 0, 255} }},
	{{ {0, 10, 10}, 0, {880, -16}, {0, 127, 0, 255} }},
	{{ {7, 7, 10}, 0, {496, 240}, {99, 80, 0, 255} }},
	{{ {0, 10, 10}, 0, {624, -16}, {0, 127, 0, 255} }},
	{{ {0, 7, 17}, 0, {240, 240}, {0, 80, 99, 255} }},
	{{ {0, 10, 10}, 0, {368, -16}, {0, 127, 0, 255} }},
	{{ {0, 0, 20}, 0, {240, 496}, {0, 0, 127, 255} }},
	{{ {-7, 7, 10}, 0, {-16, 240}, {157, 80, 0, 255} }},
	{{ {0, 10, 10}, 0, {112, -16}, {0, 127, 0, 255} }},
	{{ {-10, 0, 10}, 0, {-16, 496}, {129, 0, 0, 255} }},
	{{ {0, -7, 17}, 0, {240, 752}, {0, 176, 99, 255} }},
	{{ {-7, -7, 10}, 0, {-16, 752}, {157, 176, 0, 255} }},
	{{ {0, -10, 10}, 0, {112, 1008}, {0, 129, 0, 255} }},
	{{ {0, -10, 10}, 0, {368, 1008}, {0, 129, 0, 255} }},
};

Gfx laser_000_displaylist_mesh_layer_1_tri_0[] = {
	gsSPVertex(laser_000_displaylist_mesh_layer_1_vtx_0 + 0, 23, 0),
	gsSP2Triangles(0, 1, 2, 0, 1, 3, 2, 0),
	gsSP2Triangles(1, 4, 3, 0, 5, 4, 1, 0),
	gsSP2Triangles(6, 5, 1, 0, 5, 7, 4, 0),
	gsSP2Triangles(7, 8, 4, 0, 7, 9, 8, 0),
	gsSP2Triangles(9, 10, 8, 0, 4, 8, 11, 0),
	gsSP2Triangles(8, 12, 11, 0, 4, 11, 3, 0),
	gsSP2Triangles(3, 11, 13, 0, 11, 14, 13, 0),
	gsSP2Triangles(3, 13, 15, 0, 15, 13, 16, 0),
	gsSP2Triangles(13, 17, 16, 0, 15, 16, 18, 0),
	gsSP2Triangles(19, 15, 18, 0, 19, 18, 20, 0),
	gsSP2Triangles(21, 19, 20, 0, 2, 15, 19, 0),
	gsSP2Triangles(2, 3, 15, 0, 22, 2, 19, 0),
	gsSPEndDisplayList(),
};


Gfx mat_laser_red[] = {
	gsSPSetLights1(laser_red_lights),
	gsDPPipeSync(),
	gsDPSetCombineLERP(0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT),
	gsDPSetAlphaDither(G_AD_NOISE),
	gsSPTexture(65535, 65535, 0, 0, 1),
	gsSPEndDisplayList(),
};

Gfx mat_revert_laser_red[] = {
	gsDPPipeSync(),
	gsDPSetAlphaDither(G_AD_DISABLE),
	gsSPEndDisplayList(),
};

Gfx laser_000_displaylist_mesh_layer_1[] = {
	gsSPDisplayList(mat_laser_red),
	gsSPDisplayList(laser_000_displaylist_mesh_layer_1_tri_0),
	gsSPDisplayList(mat_revert_laser_red),
	gsSPEndDisplayList(),
};

Gfx laser_material_revert_render_settings[] = {
	gsDPPipeSync(),
	gsSPSetGeometryMode(G_LIGHTING),
	gsSPClearGeometryMode(G_TEXTURE_GEN),
	gsDPSetCombineLERP(0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT),
	gsSPTexture(65535, 65535, 0, 0, 0),
	gsDPSetEnvColor(255, 255, 255, 255),
	gsDPSetAlphaCompare(G_AC_NONE),
	gsDPSetTextureImage(G_IM_FMT_RGBA, G_IM_SIZ_16b_LOAD_BLOCK, 1, 0),
	gsDPSetTile(G_IM_FMT_RGBA, G_IM_SIZ_16b_LOAD_BLOCK, 0, 0, 7, 0, G_TX_WRAP | G_TX_NOMIRROR, 0, 0, G_TX_WRAP  | G_TX_NOMIRROR, 0, 0),
	gsDPLoadBlock(7, 0, 0, 1023, 256),
	gsDPSetTile(G_IM_FMT_RGBA, G_IM_SIZ_16b, 8, 0, 0, 0, G_TX_CLAMP | G_TX_NOMIRROR, 5, 0, G_TX_CLAMP | G_TX_NOMIRROR, 5, 0),
	gsDPSetTileSize(0, 0, 0, 124, 124),
	gsDPSetTextureImage(G_IM_FMT_RGBA, G_IM_SIZ_16b_LOAD_BLOCK, 1, 0),
	gsDPSetTile(G_IM_FMT_RGBA, G_IM_SIZ_16b_LOAD_BLOCK, 0, 256, 6, 0, G_TX_WRAP | G_TX_NOMIRROR, 0, 0, G_TX_WRAP | G_TX_NOMIRROR, 0, 0),
	gsDPLoadBlock(6, 0, 0, 1023, 256),
	gsDPSetTile(G_IM_FMT_RGBA, G_IM_SIZ_16b, 8, 256, 1, 0, G_TX_CLAMP | G_TX_NOMIRROR, 5, 0, G_TX_CLAMP | G_TX_NOMIRROR, 5, 0),
	gsDPSetTileSize(1, 0, 0, 124, 124),
	gsSPEndDisplayList(),
};

