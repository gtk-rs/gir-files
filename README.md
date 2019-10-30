# gir-files

This repository is used to generate all `gtk-rs` crates. It contains the definitions of the GNOME libraries' APIs.

If a new GTK version was released, you can update the files by doing so:

```bash
./dl.sh && ./fix.sh
```

Please don't forget to check that [`gir`](https://github.com/gtk-rs/gir) can still run with the new files since breaking changes can appear.
