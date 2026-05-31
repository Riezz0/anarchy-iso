#!/usr/bin/env python3
"""
Network Statistics Display Application using GTK/GObject
"""

import gi
import threading
import time
import psutil
import collections

gi.require_version('Gtk', '3.0')
from gi.repository import Gtk, GObject, GLib

class NetworkStatsApp:
    def __init__(self):
        # Create main window
        self.window = Gtk.Window(title="Network Statistics")
        self.window.set_default_size(600, 400)
        self.window.set_border_width(10)
        self.window.connect("destroy", Gtk.main_quit)
        
        # Initialize data storage
        self.history_length = 60  # Store last 60 data points
        self.rx_history = collections.deque(maxlen=self.history_length)
        self.tx_history = collections.deque(maxlen=self.history_length)
        
        # Get initial network stats
        self.last_stats = self.get_network_stats()
        self.last_time = time.time()
        
        # Create UI
        self.create_ui()
        
        # Start update thread
        self.running = True
        self.update_thread = threading.Thread(target=self.update_stats)
        self.update_thread.daemon = True
        self.update_thread.start()
    
    def create_ui(self):
        """Create the user interface"""
        main_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        self.window.add(main_box)
        
        # Title
        title_label = Gtk.Label()
        title_label.set_markup("<span size='x-large' weight='bold'>Network Statistics</span>")
        main_box.pack_start(title_label, False, False, 0)
        
        # Separator
        main_box.pack_start(Gtk.Separator(), False, False, 5)
        
        # Current stats frame
        current_frame = Gtk.Frame(label="Current Statistics")
        current_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=5)
        current_frame.add(current_box)
        
        # Create labels for current stats
        self.interface_label = Gtk.Label(label="Interface: --")
        self.rx_rate_label = Gtk.Label(label="Download: --")
        self.tx_rate_label = Gtk.Label(label="Upload: --")
        self.total_rx_label = Gtk.Label(label="Total Downloaded: --")
        self.total_tx_label = Gtk.Label(label="Total Uploaded: --")
        
        for label in [self.interface_label, self.rx_rate_label, self.tx_rate_label, 
                     self.total_rx_label, self.total_tx_label]:
            label.set_xalign(0)
            label.set_margin_start(10)
            current_box.pack_start(label, False, False, 2)
        
        main_box.pack_start(current_frame, False, False, 5)
        
        # Details frame
        details_frame = Gtk.Frame(label="Connection Details")
        details_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=5)
        details_frame.add(details_box)
        
        # TreeView for network connections
        scrolled_window = Gtk.ScrolledWindow()
        scrolled_window.set_policy(Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC)
        scrolled_window.set_min_content_height(150)
        
        # Create list store and tree view
        self.connection_store = Gtk.ListStore(str, str, str, str, str)
        treeview = Gtk.TreeView(model=self.connection_store)
        
        # Create columns
        columns = [
            ("PID", 0),
            ("Local Address", 1),
            ("Remote Address", 2),
            ("Status", 3),
            ("Process", 4)
        ]
        
        for title, col_id in columns:
            renderer = Gtk.CellRendererText()
            column = Gtk.TreeViewColumn(title, renderer, text=col_id)
            column.set_resizable(True)
            treeview.append_column(column)
        
        scrolled_window.add(treeview)
        details_box.pack_start(scrolled_window, True, True, 0)
        
        # Update button
        self.update_button = Gtk.Button(label="Refresh Connections")
        self.update_button.connect("clicked", self.update_connections)
        details_box.pack_start(self.update_button, False, False, 5)
        
        main_box.pack_start(details_frame, True, True, 0)
        
        # Status bar
        self.status_label = Gtk.Label(label="Ready")
        self.status_label.set_xalign(0)
        main_box.pack_start(self.status_label, False, False, 5)
    
    def get_network_stats(self):
        """Get current network statistics"""
        stats = {}
        net_io = psutil.net_io_counters(pernic=True)
        
        # Find the primary interface (usually the one with most traffic)
        primary_iface = None
        max_bytes = 0
        
        for iface, data in net_io.items():
            total_bytes = data.bytes_sent + data.bytes_recv
            if total_bytes > max_bytes and iface != 'lo':  # Skip loopback
                max_bytes = total_bytes
                primary_iface = iface
        
        if primary_iface:
            stats['interface'] = primary_iface
            stats['bytes_sent'] = net_io[primary_iface].bytes_sent
            stats['bytes_recv'] = net_io[primary_iface].bytes_recv
            stats['packets_sent'] = net_io[primary_iface].packets_sent
            stats['packets_recv'] = net_io[primary_iface].packets_recv
            stats['errin'] = net_io[primary_iface].errin
            stats['errout'] = net_io[primary_iface].errout
            stats['dropin'] = net_io[primary_iface].dropin
            stats['dropout'] = net_io[primary_iface].dropout
        
        return stats
    
    def format_bytes(self, bytes):
        """Format bytes to human readable format"""
        for unit in ['B', 'KB', 'MB', 'GB', 'TB']:
            if bytes < 1024.0:
                return f"{bytes:.2f} {unit}"
            bytes /= 1024.0
        return f"{bytes:.2f} PB"
    
    def format_rate(self, bytes_per_sec):
        """Format bytes per second"""
        return f"{self.format_bytes(bytes_per_sec)}/s"
    
    def update_ui(self):
        """Update UI with current statistics"""
        current_stats = self.get_network_stats()
        current_time = time.time()
        
        if current_stats and self.last_stats:
            time_diff = current_time - self.last_time
            
            # Calculate rates
            rx_rate = (current_stats['bytes_recv'] - self.last_stats['bytes_recv']) / time_diff
            tx_rate = (current_stats['bytes_sent'] - self.last_stats['bytes_sent']) / time_diff
            
            # Update history
            self.rx_history.append(rx_rate)
            self.tx_history.append(tx_rate)
            
            # Update labels
            self.interface_label.set_text(f"Interface: {current_stats['interface']}")
            self.rx_rate_label.set_text(f"Download: {self.format_rate(rx_rate)}")
            self.tx_rate_label.set_text(f"Upload: {self.format_rate(tx_rate)}")
            self.total_rx_label.set_text(f"Total Downloaded: {self.format_bytes(current_stats['bytes_recv'])}")
            self.total_tx_label.set_text(f"Total Uploaded: {self.format_bytes(current_stats['bytes_sent'])}")
            
            # Update status
            self.status_label.set_text(f"Last update: {time.strftime('%H:%M:%S')}")
            
            # Store for next update
            self.last_stats = current_stats
            self.last_time = current_time
    
    def update_connections(self, widget=None):
        """Update network connections list"""
        # Clear existing entries
        self.connection_store.clear()
        
        try:
            connections = psutil.net_connections(kind='inet')
            
            for conn in connections:
                if conn.status == 'LISTEN':
                    continue  # Skip listening sockets for brevity
                
                pid = str(conn.pid) if conn.pid else "N/A"
                
                # Get local address
                if conn.laddr:
                    local_addr = f"{conn.laddr.ip}:{conn.laddr.port}"
                else:
                    local_addr = "N/A"
                
                # Get remote address
                if conn.raddr:
                    remote_addr = f"{conn.raddr.ip}:{conn.raddr.port}"
                else:
                    remote_addr = "N/A"
                
                # Get process name
                process_name = "N/A"
                if conn.pid:
                    try:
                        p = psutil.Process(conn.pid)
                        process_name = p.name()
                    except (psutil.NoSuchProcess, psutil.AccessDenied):
                        process_name = "Unknown"
                
                self.connection_store.append([
                    pid,
                    local_addr,
                    remote_addr,
                    conn.status,
                    process_name
                ])
        except Exception as e:
            print(f"Error updating connections: {e}")
    
    def update_stats(self):
        """Background thread to update statistics"""
        while self.running:
            time.sleep(1)  # Update every second
            GLib.idle_add(self.update_ui)
    
    def run(self):
        """Run the application"""
        self.window.show_all()
        self.update_connections()  # Initial update
        Gtk.main()

def main():
    app = NetworkStatsApp()
    app.run()

if __name__ == "__main__":
    main()
