/* ssl.vapi generated by valac 0.28.1, do not modify. */

namespace Parole {
	[CCode (cheader_filename = "src/main.h")]
	[GtkTemplate (ui = "/de/hannenz/parole/window.ui")]
	public class ApplicationWindow : Gtk.ApplicationWindow {
		protected Xml.Doc* XmlDoc;
		public bool passwords_visible;
		public ApplicationWindow (Gtk.Application application);
		[GtkCallback]
		public void on_lock_button_clicked ();
		[GtkCallback]
		public void on_password_entry_activated (Gtk.Entry entry);
		public void open (GLib.File file);
		public void render_password (Gtk.CellRendererText cell, Gtk.TreeModel model, Gtk.TreeIter iter);
	}
	[CCode (cheader_filename = "src/main.h")]
	public class Parole : Gtk.Application {
		public Parole ();
		public override void activate ();
		public override void open (GLib.File[] files, string hint);
	}
	[CCode (cheader_filename = "src/main.h")]
	public class PasswordEntry {
		public string remark;
		public string secret;
		public string title;
		public string url;
		public string username;
		public PasswordEntry ();
	}
	[CCode (cheader_filename = "src/main.h")]
	public class PasswordEntryDialog : Gtk.Dialog {
		public global::Parole.PasswordEntry pwEntry;
		public PasswordEntryDialog (global::Parole.PasswordEntry? pwEntry);
	}
	[CCode (cheader_filename = "src/main.h")]
	public static int main (string[] args);
}
