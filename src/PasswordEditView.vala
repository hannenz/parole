using Gtk;

namespace Parole {
	
	[GtkTemplate (ui="/de/hannenz/parole/ui/password_edit_view.ui")]
	public class PasswordEditView : Gtk.Grid {

		/* [GtkChild] */
		/* private Gtk.ComboBox category_select; */

		[GtkChild]
		private Gtk.Entry title_entry;

		[GtkChild]
		private Gtk.Entry url_entry;

		[GtkChild]
		private Gtk.Entry username_entry;

		[GtkChild]
		private Gtk.Entry secret_entry;

		[GtkChild]
		private Gtk.TextView remark_entry;

		[GtkChild]
		private Gtk.Spinner pwned_spinner;

		[GtkChild]
		private Gtk.Label pwned_label;

		[GtkChild]
		private Gtk.Image image;

		[GtkChild]
		private Gtk.Image test_image;

		private PasswordGenerator generator;

		private string category;

		public PasswordEntry password_entry;

		public signal void pwned ();

		[GtkCallback]
		private void on_generate_password_button_clicked () {
			generator.regenerate_password ();
			generator.show_all ();
		}

		public PasswordEditView (PasswordEntry? password_entry, string category) {

			this.password_entry = password_entry;
			
			if (password_entry != null) {
				set_password_entry (password_entry);
			}

			this.category = category;
			generator = new PasswordGenerator ();
			generator.set_relative_to (secret_entry);
			check_if_pawned ();

			// Show password on focus, hide on blur
			secret_entry.focus_in_event.connect ( () => {
				secret_entry.set_visibility (true);
				return false;
			});
			secret_entry.focus_out_event.connect ( () => {
				secret_entry.set_visibility (false);
				return false;
			});

		}



		private void check_if_pawned () {

			var password = secret_entry.get_text ();
			if (password.length == 0) {
				return;
			}
			debug ("Checking password:  %s\n".printf (password));

			// Get SHA1 hash of password
			var hash = GLib.Checksum.compute_for_string (ChecksumType.SHA1, password);
			var hash_prefix = hash.substring (0, 5);
			var hash_suffix = hash.substring (5, -1);

			string url = "https://api.pwnedpasswords.com/range/%s".printf (hash_prefix);

			var session = new Soup.Session ();
			var message = new Soup.Message ("GET", url);

			pwned_spinner.start ();
			session.queue_message (message, (session, message) => {
				pwned_spinner.stop ();
				pwned_spinner.hide ();
				try {
					var regex = new Regex ("%s".printf (hash_suffix), RegexCompileFlags.CASELESS, 0);
					if (regex.match ((string)message.response_body.data, 0)) {
						pwned_label.set_markup ("<span color=\"#c00000\">✕</span>");
						pwned ();
					}
					else {
						pwned_label.set_markup ("<span color=\"#00c000\">✔</span>");
					}
				}
				catch (Error e) {
					stderr.printf ("Regex failed\n");
				}
				pwned_label.show ();
			});
		}



		public PasswordEntry get_password_entry () {
			password_entry.title = title_entry.get_text ();
			password_entry.url = url_entry.get_text ();
			password_entry.username = username_entry.get_text ();
			password_entry.secret = secret_entry.get_text ();
			password_entry.remark = remark_entry.buffer.text;
			//TODO: get pixbuf to base64encoded string

			return password_entry;
		}



		public void set_password_entry (PasswordEntry password_entry) {
			if (password_entry.title != null) {
				title_entry.set_text (password_entry.title);
			}
			if (password_entry.url != null) {
				url_entry.set_text (password_entry.url);
			}
			if (password_entry.username != null) {
				username_entry.set_text (password_entry.username);
			}
			if (password_entry.secret != null) {
				secret_entry.set_text (password_entry.secret);
			}
			if (password_entry.remark != null) {
				remark_entry.buffer.text = password_entry.remark;
			}
			if (password_entry.pixbuf != null) {
				test_image.set_from_pixbuf (password_entry.pixbuf);
				test_image.get_style_context ().add_class (Granite.STYLE_CLASS_CARD);
			}
		}

		[GtkCallback]
		private void select_image_from_disk () {
			var  dlg = new Gtk.FileChooserDialog ("Select image", null, 
												  Gtk.FileChooserAction.OPEN, "_Cancel",
												  Gtk.ResponseType.CANCEL, "_Open", Gtk.ResponseType.ACCEPT);

			var filter = new Gtk.FileFilter ();
			dlg.set_filter (filter);
			filter.add_mime_type ("image/jpeg");
			filter.add_mime_type ("image/png");

			if (dlg.run () == Gtk.ResponseType.ACCEPT) {

				var filename = dlg.get_filename ();

				debug (filename);

				try {
					password_entry.pixbuf = new Gdk.Pixbuf.from_file_at_scale (filename, -1, 48, true);
					test_image.set_from_pixbuf (password_entry.pixbuf);
				}
				catch (Error e) {
					stderr.printf ("Error: %s\n", e.message);
				}
			}

			dlg.close ();
			dlg.destroy ();
		}
	}
}
