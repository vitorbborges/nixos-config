{ config, pkgs, ... }:

{
  programs.gemini-cli = {
    enable = true;

    commands.changelog = {
      prompt =
        ''
        Your task is to parse the `<version>`, `<change_type>`, and `<message>` from their input and use the `write_file` tool to correctly update the `CHANGELOG.md` file.
        '';
      description = "Adds a new entry to the project's CHANGELOG.md file.";
    };
  };
}
