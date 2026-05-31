#!/usr/bin/env python3
import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk, Gdk, Pango
import os

def get_pywal_colors():
    """Load Pywal color scheme"""
    colors = {}
    try:
        with open(f"{os.environ['HOME']}/.cache/wal/colors") as f:
            for i, line in enumerate(f):
                colors[f'color{i}'] = line.strip()
    except FileNotFoundError:
        for i in range(16):
            colors[f'color{i}'] = "#000000"
    return colors

class PixelPerfectShortcuts(Gtk.Window):
    def __init__(self):
        super().__init__(title="HyprBinds")
        colors = get_pywal_colors()
        self.set_default_size(450, 650)
        self.set_position(Gtk.WindowPosition.CENTER)
        self.set_border_width(10)
        self.apply_styles(colors)
        self.create_layout(colors)

    def apply_styles(self, colors):
        css_provider = Gtk.CssProvider()
        css = f"""
        * {{
            font-family: 'Fira Code', monospace;
        }}
        window {{
            background-color: {colors['color0']};
        }}
        .category {{
            color: {colors['color2']};
            font-weight: bold;
            font-size: 1.2em;
            margin-top: 15px;
            margin-bottom: 5px;
            margin-left: 20px;
        }}
        .header {{
            color: {colors['color3']};
            font-weight: bold;
            margin-bottom: 5px;
        }}
        .keybind {{
            color: {colors['color4']};
            font-weight: bold;
            min-width: 200px;
        }}
        .description {{
            color: {colors['color7']};
            min-width: 300px;
        }}
        """
        css_provider.load_from_data(css.encode())
        Gtk.StyleContext.add_provider_for_screen(
            Gdk.Screen.get_default(),
            css_provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        )

    def create_layout(self, colors):
        scrolled = Gtk.ScrolledWindow()
        scrolled.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC)
        self.add(scrolled)

        main_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=0)
        scrolled.add(main_box)

        all_binds = self.get_categorized_binds()

        category_order = [
            'terminal',
            'workspaces',
            'window management',
            'apps',
            'scratchpads',
            'system',
            'volume',
            'other'
        ]

        for category in category_order:
            if category in all_binds and all_binds[category]:
                lbl_category = Gtk.Label(label=category.upper())
                lbl_category.set_xalign(0)
                lbl_category.get_style_context().add_class("category")
                main_box.pack_start(lbl_category, False, False, 0)

                grid = Gtk.Grid()
                grid.set_column_spacing(30)
                grid.set_row_spacing(3)
                grid.set_margin_start(20)
                grid.set_margin_end(20)
                grid.set_margin_bottom(10)
                main_box.pack_start(grid, False, False, 0)

                key_header = Gtk.Label(label="KEYBIND")
                key_header.set_xalign(0)
                key_header.get_style_context().add_class("header")
                desc_header = Gtk.Label(label="DESCRIPTION")
                desc_header.set_xalign(0)
                desc_header.get_style_context().add_class("header")
                grid.attach(key_header, 0, 0, 1, 1)
                grid.attach(desc_header, 1, 0, 1, 1)

                for i, (keybind, description) in enumerate(all_binds[category], start=1):
                    lbl_key = Gtk.Label(label=keybind)
                    lbl_key.set_xalign(0)
                    lbl_key.get_style_context().add_class("keybind")

                    lbl_desc = Gtk.Label(label=description)
                    lbl_desc.set_xalign(0)
                    lbl_desc.get_style_context().add_class("description")
                    lbl_desc.set_line_wrap(True)

                    grid.attach(lbl_key, 0, i, 1, 1)
                    grid.attach(lbl_desc, 1, i, 1, 1)

        font_desc = Pango.FontDescription("MesloLGL Nerd Font Bold 12")
        def apply_font(widget):
            if isinstance(widget, Gtk.Label):
                widget.override_font(font_desc)
                widget.set_ellipsize(Pango.EllipsizeMode.END)
            elif hasattr(widget, 'get_children'):
                for child in widget.get_children():
                    apply_font(child)
        apply_font(main_box)

    def get_categorized_binds(self):
        categories = {cat: [] for cat in ['terminal', 'workspaces', 'window management', 'apps', 'scratchpads', 'system', 'volume', 'other']}

        # --- 1. Extract from kitty.conf ---
        try:
            kitty_path = f"{os.environ['HOME']}/.config/kitty/kitty.conf"
            if os.path.exists(kitty_path):
                with open(kitty_path) as f:
                    for line in f:
                        line = line.strip()
                        if line.startswith('map '):
                            # format: map ctrl+t new_tab
                            parts = line.split(' ', 2)
                            if len(parts) >= 3:
                                keys = parts[1].upper()
                                action = parts[2].replace('_', ' ').capitalize()
                                categories['terminal'].append((keys, action))
        except Exception as e:
            print(f"Error reading kitty.conf: {e}")

        # --- 2. Extract from Hyprland binds.conf ---
        try:
            hypr_path = f"{os.environ['HOME']}/.config/hypr/binds.conf"
            with open(hypr_path) as f:
                for line in f:
                    line = line.strip()
                    if not line.startswith('bind =') or 'SUPER' not in line.upper() or '#' not in line:
                        continue

                    cmd_part, description = line.split('#', 1)
                    cmd_part = cmd_part.split('=', 1)[1].strip()
                    key_parts = [x.strip() for x in cmd_part.split(',')[:2]]
                    keybind = ', '.join(key_parts).replace('minus', '-').replace('equal', '=').replace('backslash', '\\')
                    
                    description = description.strip().capitalize()
                    d_low = description.lower()

                    if any(k in keybind for k in ['-', '=', '\\']) or 'volume' in d_low:
                        categories['volume'].append((keybind, description))
                    elif 'window' in d_low:
                        categories['window management'].append((keybind, description))
                    elif 'launch' in d_low:
                        categories['apps'].append((keybind, description))
                    elif 'workspace' in d_low:
                        categories['workspaces'].append((keybind, description))
                    elif 'scratchpad' in d_low:
                        categories['scratchpads'].append((keybind, description))
                    elif 'hyprland' in d_low:
                        categories['system'].append((keybind, description))
                    else:
                        categories['other'].append((keybind, description))
        except Exception as e:
            print(f"Error reading Hyprland binds: {e}")

        return categories

if __name__ == "__main__":
    win = PixelPerfectShortcuts()
    win.connect("destroy", Gtk.main_quit)
    win.show_all()
    Gtk.main()
