#ifndef AVATAR_CONFIGURE
#define AVATAR_CONFIGURE
// When this variable is 1, avatar shader features are disabled and the keywords below are used.
// When this variable is 0, the avatar shader falls back to the normal shader behavior for SVN compatibility.
#define REQUIRE_BAKE_AVATAR_KEYWORDS 1

#if REQUIRE_BAKE_AVATAR_KEYWORDS

// Universal Keywords
    #define _NORMALMAP
    //#define _ACES 1

// Custom Keywords
    #if  defined(AVATAR_LIT)
        // #define _MATCAP
        // #define _MATCAP_FIX_EDGE_FLAW
    #elif defined(AVATAR_SKIN)
        #define _RIM_LIGHT
        #define _RIMMASK_VIEW
        #define _DUAL_SPECULAR
    #elif defined(AVATAR_HAIR)

    #elif defined(AVATAR_EYE)
        #define _REFMODE_POM
        #define _SHARP_HIGHTLIGHT
    #endif
#endif

#endif 
