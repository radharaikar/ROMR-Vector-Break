import os
from PIL import Image

OUT_DIR = r"C:\Users\dalia\.gemini\antigravity\scratch\ROMR-Vector-Break\assets\sprites"
os.makedirs(OUT_DIR, exist_ok=True)

C_CLEAR = (0, 0, 0, 0)

# Colors
CYAN_CORE = (64, 230, 255, 255)
CYAN_BRIGHT = (140, 245, 255, 255)
CYAN_DARK = (15, 80, 110, 255)
EMERALD_CORE = (50, 240, 150, 255)
EMERALD_BRIGHT = (160, 255, 200, 255)
EMERALD_DARK = (10, 80, 45, 255)
MAGENTA_CORE = (255, 45, 180, 255)
MAGENTA_BRIGHT = (255, 160, 230, 255)
MAGENTA_DARK = (90, 10, 60, 255)
AMBER_CORE = (255, 180, 40, 255)
AMBER_BRIGHT = (255, 225, 120, 255)
AMBER_DARK = (90, 55, 10, 255)
DARK_HULL = (12, 16, 28, 255)
WHITE = (255, 255, 255, 255)

def generate_nanocell():
    img = Image.new("RGBA", (24, 24), C_CLEAR)
    px = img.load()
    # Hexagonal / rounded capsule
    # Outer capsule ring
    for x in range(5, 19):
        for y in range(4, 20):
            # Hexagonal distance
            dx = abs(x - 11.5)
            dy = abs(y - 11.5)
            if dx * 1.2 + dy <= 10.5:
                # Border
                if dx * 1.2 + dy >= 8.5:
                    px[x, y] = CYAN_DARK
                elif dx * 1.2 + dy >= 6.5:
                    px[x, y] = EMERALD_DARK
                else:
                    px[x, y] = EMERALD_CORE
    
    # Inner medical cross / energy core
    for i in range(9, 15):
        px[i, 11] = EMERALD_BRIGHT
        px[i, 12] = WHITE
        px[11, i] = EMERALD_BRIGHT
        px[12, i] = WHITE
    
    px[11, 11] = WHITE
    px[12, 12] = WHITE
    
    img.save(os.path.join(OUT_DIR, "pickup_nanocell.png"))
    print("Generated pickup_nanocell.png")

def generate_fragment():
    img = Image.new("RGBA", (16, 16), C_CLEAR)
    px = img.load()
    # Kinetic diamond / octahedron
    for x in range(2, 14):
        for y in range(2, 14):
            dx = abs(x - 7.5)
            dy = abs(y - 7.5)
            if dx + dy <= 6.5:
                if dx + dy >= 5.0:
                    px[x, y] = MAGENTA_DARK if y > 7.5 else CYAN_DARK
                elif dx + dy >= 3.0:
                    px[x, y] = MAGENTA_CORE if y > 7.5 else CYAN_CORE
                else:
                    px[x, y] = CYAN_BRIGHT if y <= 7.5 else MAGENTA_BRIGHT
    
    # High-glow specular facet
    px[7, 6] = WHITE
    px[8, 6] = WHITE
    px[7, 7] = WHITE
    px[8, 7] = CYAN_BRIGHT
    
    img.save(os.path.join(OUT_DIR, "pickup_fragment.png"))
    print("Generated pickup_fragment.png")

def generate_reconstruction_core():
    img = Image.new("RGBA", (24, 24), C_CLEAR)
    px = img.load()
    # Circular neural core
    for x in range(3, 21):
        for y in range(3, 21):
            dx = x - 11.5
            dy = y - 11.5
            dist = (dx*dx + dy*dy) ** 0.5
            if dist <= 8.5:
                if dist >= 7.0:
                    px[x, y] = AMBER_DARK
                elif dist >= 5.0:
                    px[x, y] = (30, 20, 10, 255)
                elif dist >= 2.5:
                    px[x, y] = AMBER_CORE
                else:
                    px[x, y] = AMBER_BRIGHT
    
    # Central nexus spark
    px[11, 11] = WHITE
    px[12, 11] = WHITE
    px[11, 12] = WHITE
    px[12, 12] = WHITE
    
    img.save(os.path.join(OUT_DIR, "reconstruction_core.png"))
    print("Generated reconstruction_core.png")

def generate_skins():
    # Load base player ship
    base_path = os.path.join(OUT_DIR, "player_ship.png")
    base_img = Image.open(base_path).convert("RGBA")
    
    # 1. Prototype Skin: Dark stealth obsidian with golden/amber conduits
    proto = base_img.copy()
    proto_px = proto.load()
    for x in range(proto.width):
        for y in range(proto.height):
            r, g, b, a = proto_px[x, y]
            if a > 0:
                # If cyan highlights (b > 180 and g > 150) -> turn golden amber
                if b > 160 and g > 130 and r < 120:
                    proto_px[x, y] = (255, 190, 40, a)
                # If metallic titanium -> darken to obsidian navy
                elif r > 100 or g > 100 or b > 100:
                    proto_px[x, y] = (int(r * 0.35 + 10), int(g * 0.35 + 15), int(b * 0.45 + 30), a)
    proto.save(os.path.join(OUT_DIR, "player_ship_prototype.png"))
    print("Generated player_ship_prototype.png")
    
    # 2. Squad Skin: Military slate with crimson trim
    squad = base_img.copy()
    squad_px = squad.load()
    for x in range(squad.width):
        for y in range(squad.height):
            r, g, b, a = squad_px[x, y]
            if a > 0:
                if b > 160 and g > 130 and r < 120:
                    squad_px[x, y] = (255, 50, 75, a) # Crimson trim
                elif r > 100 or g > 100 or b > 100:
                    squad_px[x, y] = (int(r * 0.7 + 30), int(g * 0.7 + 10), int(b * 0.7 + 10), a) # Slate gunmetal
    squad.save(os.path.join(OUT_DIR, "player_ship_squad.png"))
    print("Generated player_ship_squad.png")
    
    # 3. Vector Resonant Skin: Iridescent magenta / chromatic violet
    vect = base_img.copy()
    vect_px = vect.load()
    for x in range(vect.width):
        for y in range(vect.height):
            r, g, b, a = vect_px[x, y]
            if a > 0:
                if b > 160 and g > 130 and r < 120:
                    vect_px[x, y] = (255, 60, 220, a) # Neon magenta
                elif r > 100 or g > 100 or b > 100:
                    vect_px[x, y] = (int(r * 0.5 + 80), int(g * 0.3 + 20), int(b * 0.7 + 70), a) # Deep violet
    vect.save(os.path.join(OUT_DIR, "player_ship_vector.png"))
    print("Generated player_ship_vector.png")

if __name__ == "__main__":
    generate_nanocell()
    generate_fragment()
    generate_reconstruction_core()
    generate_skins()
    print("All progression pixel art generated successfully!")
