namespace Astal {
public class Process : Object {
    private void read_stream(DataInputStream stream, bool err) {
        stream.read_line_utf8_async.begin(Priority.DEFAULT, null, (_, res) => {
            try {
                var output = stream.read_line_utf8_async.end(res);
                if (output != null) {
                    if (err)
                        stdout(output.strip());
                    else
                        stderr(output.strip());

                    read_stream(stream, err);
                }
            } catch (Error err) {
                printerr("%s\n", err.message);
            }
        });
    }

    private DataInputStream out_stream;
    private DataInputStream err_stream;
    private DataOutputStream in_stream;
    private Subprocess process;
    public string[] argv { construct; get; }

    public signal void stdout (string out);
    public signal void stderr (string err);

    public void kill() {
        process.force_exit();
    }

    public void write(string in) throws Error {
        in_stream.put_string(in);
    }

    public void write_async(string in) {
        in_stream.write_all_async.begin(
            in.data,
            Priority.DEFAULT, null, (_, res) => {
                try {
                    in_stream.write_all_async.end(res, null);
                } catch (Error err) {
                    printerr("%s\n", err.message);
                }
            }
        );
    }

    public Process.subprocessv(string[] cmd) throws Error {
        Object(argv: cmd);
        process = new Subprocess.newv(cmd,
            SubprocessFlags.STDIN_PIPE |
            SubprocessFlags.STDERR_PIPE |
            SubprocessFlags.STDOUT_PIPE
        );
        out_stream = new DataInputStream(process.get_stdout_pipe());
        err_stream = new DataInputStream(process.get_stderr_pipe());
        in_stream = new DataOutputStream(process.get_stdin_pipe());
        read_stream(out_stream, true);
        read_stream(err_stream, false);
    }

    public static Process subprocess(string cmd) throws Error {
        string[] argv;
        Shell.parse_argv(cmd, out argv);
        return new Process.subprocessv(argv);
    }

    public static string execv(string[] cmd) throws Error {
        var process = new Subprocess.newv(
            cmd,
            SubprocessFlags.STDERR_PIPE |
            SubprocessFlags.STDOUT_PIPE
        );

        string err_str, out_str;
        process.communicate_utf8(null, null, out out_str, out err_str);
        var success = process.get_successful();
        process.dispose();
        if (success)
            return out_str.strip();
        else
            throw new ProcessError.FAILED(err_str.strip());
    }

    public static string exec(string cmd) throws Error {
        string[] argv;
        Shell.parse_argv(cmd, out argv);
        return Process.execv(argv);
    }

    public Process.exec_asyncv(string[] cmd) throws Error {
        Object(argv: cmd);
        process = new Subprocess.newv(cmd,
            SubprocessFlags.STDERR_PIPE |
            SubprocessFlags.STDOUT_PIPE
        );

        process.communicate_utf8_async.begin(null, null, (_, res) => {
            string err_str, out_str;
            try {
                process.communicate_utf8_async.end(res, out out_str, out err_str);
                if (process.get_successful())
                    stdout(out_str.strip());
                else
                    stderr(err_str.strip());
            } catch (Error err) {
                printerr("%s\n", err.message);
            } finally {
                dispose();
            }
        });
    }

    public static Process exec_async(string cmd) throws Error {
        string[] argv;
        Shell.parse_argv(cmd, out argv);
        return new Process.exec_asyncv(argv);
    }
}
errordomain ProcessError {
    FAILED
}
}
