{ config, lib, pkgs, ... }:

let
  c = config.lib.stylix.colors.withHashtag;
  base = config.lib.stylix.colors;

  hexDigits = "0123456789abcdef";

  toHexByte = n:
    let
      hi = builtins.div n 16;
      lo = n - hi * 16;
    in "${builtins.substring hi 1 hexDigits}${builtins.substring lo 1 hexDigits}";

  blend = hex: factor:
    let
      r = lib.fromHexString (builtins.substring 0 2 hex);
      g = lib.fromHexString (builtins.substring 2 2 hex);
      b = lib.fromHexString (builtins.substring 4 2 hex);
    in "#${toHexByte (builtins.floor (r * factor))}${toHexByte (builtins.floor (g * factor))}${toHexByte (builtins.floor (b * factor))}";

in
{
  xdg.configFile."opencode/themes/stylix.json" = {
    text = builtins.toJSON {
      "$schema" = "https://opencode.ai/theme.json";
      defs = {
        background = c.base00;
        panel = c.base01;
        element = c.base02;
        text = c.base05;
        muted = c.base04;
        primary = c.base0D;
        secondary = c.base0C;
        accent = c.base0E;
        border = c.base02;
        borderActive = c.base0D;
        borderSubtle = c.base01;
        error = c.base08;
        warning = c.base09;
        success = c.base0B;
        info = c.base0C;
        diffAdd = c.base0B;
        diffRemove = c.base08;
        diffContext = c.base04;
        diffAddedBg = blend base.base0B 0.15;
        diffRemovedBg = blend base.base08 0.15;
        diffHighlightAdded = blend base.base0B 0.30;
        diffHighlightRemoved = blend base.base08 0.30;
        syntaxComment = c.base03;
        syntaxKeyword = c.base0E;
        syntaxFunction = c.base0D;
        syntaxVariable = c.base05;
        syntaxString = c.base0B;
        syntaxNumber = c.base09;
        syntaxType = c.base0C;
        syntaxOperator = c.base05;
        syntaxPunctuation = c.base04;
      };
      theme = {
        primary = "primary";
        secondary = "secondary";
        accent = "accent";
        error = "error";
        warning = "warning";
        success = "success";
        info = "info";
        text = "text";
        textMuted = "muted";
        background = "background";
        backgroundPanel = "panel";
        backgroundElement = "element";
        border = "border";
        borderActive = "borderActive";
        borderSubtle = "borderSubtle";
        diffAdded = "diffAdd";
        diffRemoved = "diffRemove";
        diffContext = "diffContext";
        diffHunkHeader = "primary";
        diffAddedBg = "diffAddedBg";
        diffRemovedBg = "diffRemovedBg";
        diffHighlightAdded = "diffHighlightAdded";
        diffHighlightRemoved = "diffHighlightRemoved";
        diffLineNumber = "muted";
        diffAddedLineNumberBg = "diffAddedBg";
        diffRemovedLineNumberBg = "diffRemovedBg";
        diffContextBg = "background";
        markdownText = "text";
        markdownHeading = "primary";
        markdownLink = "secondary";
        markdownLinkText = "secondary";
        markdownCode = "accent";
        markdownBlockQuote = "border";
        markdownEmph = "warning";
        markdownStrong = "error";
        markdownHorizontalRule = "border";
        markdownListItem = "text";
        markdownListEnumeration = "muted";
        markdownImage = "text";
        markdownImageText = "muted";
        markdownCodeBlock = "text";
        syntaxComment = "syntaxComment";
        syntaxKeyword = "syntaxKeyword";
        syntaxFunction = "syntaxFunction";
        syntaxVariable = "syntaxVariable";
        syntaxString = "syntaxString";
        syntaxNumber = "syntaxNumber";
        syntaxType = "syntaxType";
        syntaxOperator = "syntaxOperator";
        syntaxPunctuation = "syntaxPunctuation";
        thinkingOpacity = 0.72;
      };
    };
  };

  xdg.configFile."opencode/tui.json" = {
    text = builtins.toJSON {
      "$schema" = "https://opencode.ai/tui.json";
      theme = "stylix";
    };
  };
}
