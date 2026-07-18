import gi
import json
import os
gi.require_version('Gtk', '4.0')
from gi.repository import Gtk, Gdk

class KeyboardLayoutApp(Gtk.Application):
    def __init__(self):
        super().__init__(application_id='com.layout.viewer')
        self.colors = self.load_pywal_colors()

    def load_pywal_colors(self):
        # Fallback colors
        colors = {
            "background": "#1a1b26", "foreground": "#a9b1d6",
            "color1": "#f7768e", "color2": "#9ece6a", "color4": "#7aa2f7"
        }
        wal_path = os.path.expanduser("~/.cache/wal/colors.json")
        if os.path.exists(wal_path):
            with open(wal_path, 'r') as f:
                data = json.load(f)
                colors = {
                    "background": data['special']['background'],
                    "foreground": data['special']['foreground'],
                    "color1": data['colors']['color1'],
                    "color2": data['colors']['color2'],
                    "color4": data['colors']['color4']
                }
        return colors

    def do_activate(self):
        win = Gtk.ApplicationWindow(application=self, title="Arabic Phonetic Layout Viewer")
        win.set_default_size(1050, 550)

        main_vbox = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=20)
        # Fixed: Replaced set_margin_all with individual margin setters
        main_vbox.set_margin_top(25)
        main_vbox.set_margin_bottom(25)
        main_vbox.set_margin_start(25)
        main_vbox.set_margin_end(25)
        win.set_child(main_vbox)

        kb_vbox = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=8)
        main_vbox.append(kb_vbox)

        # Updated data mapping
        rows = [
            [("`", "ذ", "ّ"), ("1", "١", "!"), ("2", "٢", "@"), ("3", "٣", "#"), ("4", "٤", "$"), ("5", "٥", "%"), ("6", "٦", "^"), ("7", "٧", "&"), ("8", "٨", "*"), ("9", "٩", "("), ("0", "٠", ")"), ("-", "-", "_"), ("=", "=", "+"), ("\\", "ّ", "|")],
            [("Q", "ق", "ؤ"), ("W", "و", "ئ"), ("E", "ش", "÷"), ("R", "ر", "×"), ("T", "ت", "ط"), ("Y", "ي", "ى"), ("U", "ء", "ؤ"), ("I", "إ", "آ"), ("O", "ة", "أ"), ("P", "ا", "ٱ")],
            [("A", "ا", "ع"), ("S", "س", "ص"), ("D", "د", "ض"), ("F", "ف", "-"), ("G", "غ", "ْ"), ("H", "ه", "ح"), ("J", "ج", "'"), ("K", "ك", "خ"), ("L", "ل", "ؤ"), (";", "لا", "لآ"), ("'", "لأ", "لإ")],
            [("Z", "ز", "ذ"), ("X", "ظ", "ٌ"), ("C", "ث", "ٍ"), ("V", "ى", "ً"), ("B", "ب", "ُ"), ("N", "ن", "ِ"), ("M", "م", "َ"), (",", ",", ":"), (".", ".", ">"), ("/", "ٰ", "؟")]
        ]

        for row_data in rows:
            hbox = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=6)
            hbox.set_halign(Gtk.Align.CENTER)
            for eng, normal, shift in row_data:
                hbox.append(self.create_key(eng, normal, shift))
            kb_vbox.append(hbox)

        # Legend Section
        legend_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=30)
        legend_box.set_halign(Gtk.Align.CENTER)
        legend_box.set_margin_top(20)
        
        legend_items = [
            (self.colors['color1'], "English Reference"),
            (self.colors['foreground'], "Arabic (Normal)"),
            (self.colors['color2'], "Arabic (Shift)")
        ]

        for color, text in legend_items:
            item_hbox = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
            dot = Gtk.Box()
            dot.set_size_request(12, 12)
            dot.add_css_class("legend-dot")
            
            dot_provider = Gtk.CssProvider()
            dot_provider.load_from_data(f".legend-dot {{ background-color: {color}; border-radius: 6px; }}", -1)
            dot.get_style_context().add_provider(dot_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION)
            
            label = Gtk.Label(label=text)
            label.add_css_class("legend-text")
            
            item_hbox.append(dot)
            item_hbox.append(label)
            legend_box.append(item_hbox)

        main_vbox.append(legend_box)
        self.apply_styling()
        win.present()

    def create_key(self, eng, normal, shift):
        overlay = Gtk.Fixed()
        overlay.add_css_class("key-tile")
        overlay.set_size_request(65, 65)

        lbl_eng = Gtk.Label(label=eng)
        lbl_eng.add_css_class("eng-char")
        overlay.put(lbl_eng, 8, 8)

        lbl_shift = Gtk.Label(label=shift)
        lbl_shift.add_css_class("shift-char")
        overlay.put(lbl_shift, 42, 8)

        lbl_norm = Gtk.Label(label=normal)
        lbl_norm.add_css_class("normal-char")
        overlay.put(lbl_norm, 32, 32)

        return overlay

    def apply_styling(self):
        css_provider = Gtk.CssProvider()
        css_style = f"""
            * {{
                font-family: "MesloLGL Nerd Font Propo";
                font-weight: normal;
            }}
            window {{
                background-color: {self.colors['background']};
            }}
            .key-tile {{
                background-color: alpha({self.colors['foreground']}, 0.05);
                border: 1px solid alpha({self.colors['color4']}, 0.4);
                border-radius: 6px;
            }}
            .eng-char {{
                color: {self.colors['color1']};
                font-size: 12px;
            }}
            .shift-char {{
                color: {self.colors['color2']};
                font-size: 15px;
            }}
            .normal-char {{
                color: {self.colors['foreground']};
                font-size: 22px;
            }}
            .legend-text {{
                color: {self.colors['foreground']};
                font-size: 14px;
            }}
        """
        css_provider.load_from_data(css_style, -1)
        Gtk.StyleContext.add_provider_for_display(
            Gdk.Display.get_default(),
            css_provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        )

if __name__ == "__main__":
    app = KeyboardLayoutApp()
    app.run(None)
