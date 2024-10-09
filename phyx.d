/*
    This file is part of the Phyx distribution.

    https://github.com/senselogic/PHYX

    Copyright (C) 2021 Eric Pelzer (ecstatic.coder@gmail.com)

    Phyx is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, version 3.

    Phyx is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Phyx.  If not, see <http://www.gnu.org/licenses/>.
*/

// -- IMPORTS

import core.stdc.stdlib : exit;
import std.conv : to;
import std.file : dirEntries, exists, readText, write, SpanMode;
import std.math : round;
import std.regex : regex, replaceAll, Captures, Regex;
import std.stdio : writeln;
import std.string : endsWith, indexOf, join, lastIndexOf, replace, split, startsWith, strip, stripLeft, stripRight, toLower;

// -- VARIABLES

bool
    MediaOptionIsEnabled,
    NewlineOptionIsEnabled,
    StyleOptionIsEnabled,
    UnitOptionIsEnabled;
long[string]
    PropertyIndexMap;
double
    MinimumPixelCount;

// -- FUNCTIONS

void PrintError(
    string message
    )
{
    writeln( "*** ERROR : ", message );
}

// ~~

void Abort(
    string message
    )
{
    PrintError( message );

    exit( -1 );
}

// ~~

void Abort(
    string message,
    Exception exception
    )
{
    PrintError( message );
    PrintError( exception.msg );

    exit( -1 );
}

// ~~

bool IsFolderPath(
    string folder_path
    )
{
    return
        folder_path.endsWith( '/' )
        || folder_path.endsWith( '\\' );
}

// ~~

string GetLogicalPath(
    string path
    )
{
    return path.replace( '\\', '/' );
}

// ~~

void SplitFilePathFilter(
    string file_path_filter,
    ref string folder_path,
    ref string file_name_filter,
    ref SpanMode span_mode
    )
{
    long
        folder_path_character_count;
    string
        file_name;

    folder_path_character_count = file_path_filter.lastIndexOf( '/' ) + 1;

    folder_path = file_path_filter[ 0 .. folder_path_character_count ];
    file_name_filter = file_path_filter[ folder_path_character_count .. $ ];

    if ( folder_path.endsWith( "//" ) )
    {
        folder_path = folder_path[ 0 .. $ - 1 ];

        span_mode = SpanMode.depth;
    }
    else
    {
        span_mode = SpanMode.shallow;
    }
}

// ~~

void WriteText(
    string file_path,
    string file_text
    )
{
    file_text = file_text.stripRight();

    if ( file_text != ""
         && !file_text.endsWith( '\n' ) )
    {
        file_text ~= '\n';
    }

    try
    {
        if ( !file_path.exists()
             || file_path.readText() != file_text )
        {
            writeln( "Writing file : ", file_path );

            file_path.write( file_text );
        }
    }
    catch ( Exception exception )
    {
        Abort( "Can't write file : " ~ file_path, exception );
    }
}

// ~~

string ReadText(
    string file_path
    )
{
    string
        file_text;

    writeln( "Reading file : ", file_path );

    try
    {
        file_text = file_path.readText();
    }
    catch ( Exception exception )
    {
        Abort( "Can't read file : " ~ file_path, exception );
    }

    return file_text;
}

// ~~

long GetIndentationSpaceCount(
    string line
    )
{
    long
        indentation_space_count;

    indentation_space_count = 0;

    while ( indentation_space_count < line.length
            && line[ indentation_space_count ] == ' ' )
    {
        ++indentation_space_count;
    }

    return indentation_space_count;
}

// ~~

void MakePropertyIndexMap(
    )
{
    long
        property_index;

    property_index = 64;
    PropertyIndexMap[ "z-index:" ] = property_index++;
    PropertyIndexMap[ "position:" ] = property_index++;
    PropertyIndexMap[ "top:" ] = property_index++;
    PropertyIndexMap[ "bottom:" ] = property_index++;
    PropertyIndexMap[ "left:" ] = property_index++;
    PropertyIndexMap[ "right:" ] = property_index++;
    PropertyIndexMap[ "transform-origin:" ] = property_index++;
    PropertyIndexMap[ "transform:" ] = property_index;
    PropertyIndexMap[ "translate:" ] = property_index;
    PropertyIndexMap[ "scale:" ] = property_index;
    PropertyIndexMap[ "rotate:" ] = property_index;

    property_index = 128;
    PropertyIndexMap[ "container-type:" ] = property_index++;
    PropertyIndexMap[ "overflow:" ] = property_index++;
    PropertyIndexMap[ "overflow-y:" ] = property_index++;
    PropertyIndexMap[ "overflow-x:" ] = property_index++;
    PropertyIndexMap[ "box-sizing:" ] = property_index++;
    PropertyIndexMap[ "-unity-overflow-clip-box:" ] = property_index++;
    PropertyIndexMap[ "scrollbar-width:" ] = property_index++;
    PropertyIndexMap[ "inset:" ] = property_index++;
    PropertyIndexMap[ "margin:" ] = property_index++;
    PropertyIndexMap[ "margin-block:" ] = property_index++;
    PropertyIndexMap[ "margin-block-start:" ] = property_index++;
    PropertyIndexMap[ "margin-block-end:" ] = property_index++;
    PropertyIndexMap[ "margin-inline:" ] = property_index++;
    PropertyIndexMap[ "margin-inline-start:" ] = property_index++;
    PropertyIndexMap[ "margin-inline-end:" ] = property_index++;
    PropertyIndexMap[ "margin-top:" ] = property_index++;
    PropertyIndexMap[ "margin-bottom:" ] = property_index++;
    PropertyIndexMap[ "margin-left:" ] = property_index++;
    PropertyIndexMap[ "margin-right:" ] = property_index++;
    PropertyIndexMap[ "outline:" ] = property_index++;
    PropertyIndexMap[ "height:" ] = property_index++;
    PropertyIndexMap[ "min-height:" ] = property_index++;
    PropertyIndexMap[ "max-height:" ] = property_index++;
    PropertyIndexMap[ "width:" ] = property_index++;
    PropertyIndexMap[ "min-width:" ] = property_index++;
    PropertyIndexMap[ "max-width:" ] = property_index++;
    PropertyIndexMap[ "aspect-ratio:" ] = property_index++;
    PropertyIndexMap[ "border:" ] = property_index++;
    PropertyIndexMap[ "border-top:" ] = property_index++;
    PropertyIndexMap[ "border-bottom:" ] = property_index++;
    PropertyIndexMap[ "border-left:" ] = property_index++;
    PropertyIndexMap[ "border-right:" ] = property_index++;
    PropertyIndexMap[ "border-width:" ] = property_index++;
    PropertyIndexMap[ "border-style:" ] = property_index++;
    PropertyIndexMap[ "border-color:" ] = property_index++;
    PropertyIndexMap[ "border-image:" ] = property_index++;
    PropertyIndexMap[ "border-radius:" ] = property_index++;
    PropertyIndexMap[ "border-top-radius:" ] = property_index++;
    PropertyIndexMap[ "border-top-left-radius:" ] = property_index++;
    PropertyIndexMap[ "border-top-right-radius:" ] = property_index++;
    PropertyIndexMap[ "border-bottom-radius:" ] = property_index++;
    PropertyIndexMap[ "border-bottom-left-radius:" ] = property_index++;
    PropertyIndexMap[ "border-bottom-right-radius:" ] = property_index++;
    PropertyIndexMap[ "border-collapse:" ] = property_index++;
    PropertyIndexMap[ "padding:" ] = property_index++;
    PropertyIndexMap[ "padding-top:" ] = property_index++;
    PropertyIndexMap[ "padding-bottom:" ] = property_index++;
    PropertyIndexMap[ "padding-left:" ] = property_index++;
    PropertyIndexMap[ "padding-right:" ] = property_index++;

    property_index = 192;
    PropertyIndexMap[ "display:" ] = property_index++;
    PropertyIndexMap[ "flex:" ] = property_index++;
    PropertyIndexMap[ "flex-direction:" ] = property_index++;
    PropertyIndexMap[ "flex-wrap:" ] = property_index++;
    PropertyIndexMap[ "flex-grow:" ] = property_index++;
    PropertyIndexMap[ "flex-shrink:" ] = property_index++;
    PropertyIndexMap[ "flex-basis:" ] = property_index++;
    PropertyIndexMap[ "flex-flow:" ] = property_index++;
    PropertyIndexMap[ "grid-template:" ] = property_index++;
    PropertyIndexMap[ "grid-template-rows:" ] = property_index++;
    PropertyIndexMap[ "grid-template-columns:" ] = property_index++;
    PropertyIndexMap[ "grid-template-areas:" ] = property_index++;
    PropertyIndexMap[ "grid-auto-rows:" ] = property_index++;
    PropertyIndexMap[ "grid-gap:" ] = property_index++;
    PropertyIndexMap[ "gap:" ] = property_index++;
    PropertyIndexMap[ "row-gap:" ] = property_index++;
    PropertyIndexMap[ "column-gap:" ] = property_index++;
    PropertyIndexMap[ "grid-area:" ] = property_index++;
    PropertyIndexMap[ "grid-row:" ] = property_index++;
    PropertyIndexMap[ "grid-column:" ] = property_index++;
    PropertyIndexMap[ "justify-content:" ] = property_index++;
    PropertyIndexMap[ "justify-items:" ] = property_index++;
    PropertyIndexMap[ "justify-self:" ] = property_index++;
    PropertyIndexMap[ "align-content:" ] = property_index++;
    PropertyIndexMap[ "align-items:" ] = property_index++;
    PropertyIndexMap[ "align-self:" ] = property_index++;
    PropertyIndexMap[ "order:" ] = property_index++;
    PropertyIndexMap[ "float:" ] = property_index++;
    PropertyIndexMap[ "clear:" ] = property_index++;
    PropertyIndexMap[ "columns:" ] = property_index++;
    PropertyIndexMap[ "column-count:" ] = property_index++;
    PropertyIndexMap[ "column-width:" ] = property_index++;
    PropertyIndexMap[ "column-span:" ] = property_index++;
    PropertyIndexMap[ "column-fill:" ] = property_index++;
    PropertyIndexMap[ "column-gap:" ] = property_index++;
    PropertyIndexMap[ "column-rule:" ] = property_index++;
    PropertyIndexMap[ "column-rule-width:" ] = property_index++;
    PropertyIndexMap[ "column-rule-style:" ] = property_index++;
    PropertyIndexMap[ "column-rule-color:" ] = property_index++;
    PropertyIndexMap[ "shape-outside:" ] = property_index++;
    PropertyIndexMap[ "clip-path:" ] = property_index++;
    PropertyIndexMap[ "object-fit:" ] = property_index++;

    property_index = 256;
    PropertyIndexMap[ "content:" ] = property_index++;
    PropertyIndexMap[ "visibility:" ] = property_index++;
    PropertyIndexMap[ "opacity:" ] = property_index++;
    PropertyIndexMap[ "background:" ] = property_index++;
    PropertyIndexMap[ "background-clip:" ] = property_index++;
    PropertyIndexMap[ "background-color:" ] = property_index++;
    PropertyIndexMap[ "background-image:" ] = property_index++;
    PropertyIndexMap[ "background-origin:" ] = property_index++;
    PropertyIndexMap[ "background-position:" ] = property_index++;
    PropertyIndexMap[ "background-repeat:" ] = property_index++;
    PropertyIndexMap[ "background-size:" ] = property_index++;
    PropertyIndexMap[ "background-attachment:" ] = property_index++;
    PropertyIndexMap[ "-unity-background-scale-mode:" ] = property_index++;
    PropertyIndexMap[ "-unity-background-image-tint-color:" ] = property_index++;
    PropertyIndexMap[ "-unity-slice-top:" ] = property_index++;
    PropertyIndexMap[ "-unity-slice-bottom:" ] = property_index++;
    PropertyIndexMap[ "-unity-slice-left:" ] = property_index++;
    PropertyIndexMap[ "-unity-slice-right:" ] = property_index++;
    PropertyIndexMap[ "-unity-slice-scale:" ] = property_index++;
    PropertyIndexMap[ "mask:" ] = property_index++;
    PropertyIndexMap[ "mask-clip:" ] = property_index++;
    PropertyIndexMap[ "mask-composite:" ] = property_index++;
    PropertyIndexMap[ "mask-image:" ] = property_index++;
    PropertyIndexMap[ "mask-mode:" ] = property_index++;
    PropertyIndexMap[ "mask-origin:" ] = property_index++;
    PropertyIndexMap[ "mask-position:" ] = property_index++;
    PropertyIndexMap[ "mask-repeat:" ] = property_index++;
    PropertyIndexMap[ "mask-size:" ] = property_index++;
    PropertyIndexMap[ "box-shadow:" ] = property_index++;
    PropertyIndexMap[ "filter:" ] = property_index++;
    PropertyIndexMap[ "backdrop-filter:" ] = property_index++;

    property_index = 320;
    PropertyIndexMap[ "list-style-type:" ] = property_index++;
    PropertyIndexMap[ "direction:" ] = property_index++;
    PropertyIndexMap[ "writing-mode:" ] = property_index++;
    PropertyIndexMap[ "text-orientation:" ] = property_index++;
    PropertyIndexMap[ "line-height:" ] = property_index++;
    PropertyIndexMap[ "font:" ] = property_index++;
    PropertyIndexMap[ "font-family:" ] = property_index++;
    PropertyIndexMap[ "-unity-font:" ] = property_index++;
    PropertyIndexMap[ "-unity-font-definition:" ] = property_index++;
    PropertyIndexMap[ "font-size:" ] = property_index++;
    PropertyIndexMap[ "font-size-adjust:" ] = property_index++;
    PropertyIndexMap[ "font-optical-sizing:" ] = property_index++;
    PropertyIndexMap[ "font-weight:" ] = property_index++;
    PropertyIndexMap[ "font-style:" ] = property_index++;
    PropertyIndexMap[ "-unity-font-style:" ] = property_index++;
    PropertyIndexMap[ "font-stretch:" ] = property_index++;
    PropertyIndexMap[ "font-kerning:" ] = property_index++;
    PropertyIndexMap[ "font-language-override:" ] = property_index++;
    PropertyIndexMap[ "font-feature-settings:" ] = property_index++;
    PropertyIndexMap[ "font-variant:" ] = property_index++;
    PropertyIndexMap[ "font-variant-alternates:" ] = property_index++;
    PropertyIndexMap[ "font-variant-caps:" ] = property_index++;
    PropertyIndexMap[ "font-variant-east-asian:" ] = property_index++;
    PropertyIndexMap[ "font-variant-emoji:" ] = property_index++;
    PropertyIndexMap[ "font-variant-ligatures:" ] = property_index++;
    PropertyIndexMap[ "font-variant-numeric:" ] = property_index++;
    PropertyIndexMap[ "font-variant-position:" ] = property_index++;
    PropertyIndexMap[ "font-variation-settings:" ] = property_index++;
    PropertyIndexMap[ "hyphens:" ] = property_index++;
    PropertyIndexMap[ "white-space:" ] = property_index++;
    PropertyIndexMap[ "overflow-wrap:" ] = property_index++;
    PropertyIndexMap[ "word-wrap:" ] = property_index++;
    PropertyIndexMap[ "word-break:" ] = property_index++;
    PropertyIndexMap[ "word-spacing:" ] = property_index++;
    PropertyIndexMap[ "letter-spacing:" ] = property_index++;
    PropertyIndexMap[ "-unity-paragraph-spacing:" ] = property_index++;
    PropertyIndexMap[ "caption-side:" ] = property_index++;
    PropertyIndexMap[ "vertical-align:" ] = property_index++;
    PropertyIndexMap[ "text-align:" ] = property_index++;
    PropertyIndexMap[ "text-align-last:" ] = property_index++;
    PropertyIndexMap[ "-unity-text-align:" ] = property_index++;
    PropertyIndexMap[ "text-indent:" ] = property_index++;
    PropertyIndexMap[ "text-justify:" ] = property_index++;
    PropertyIndexMap[ "text-overflow:" ] = property_index++;
    PropertyIndexMap[ "-unity-text-overflow-position:" ] = property_index++;
    PropertyIndexMap[ "text-decoration:" ] = property_index++;
    PropertyIndexMap[ "text-decoration-line:" ] = property_index++;
    PropertyIndexMap[ "text-decoration-style:" ] = property_index++;
    PropertyIndexMap[ "text-decoration-color:" ] = property_index++;
    PropertyIndexMap[ "text-transform:" ] = property_index++;
    PropertyIndexMap[ "text-shadow:" ] = property_index++;
    PropertyIndexMap[ "-unity-text-outline-width:" ] = property_index++;
    PropertyIndexMap[ "-unity-text-outline-color:" ] = property_index++;
    PropertyIndexMap[ "-unity-text-outline:" ] = property_index++;
    PropertyIndexMap[ "color:" ] = property_index++;

    property_index = 384;
    PropertyIndexMap[ "resize:" ] = property_index++;
    PropertyIndexMap[ "scroll-behavior:" ] = property_index++;
    PropertyIndexMap[ "scroll-snap-type:" ] = property_index++;
    PropertyIndexMap[ "scroll-snap-points-y:" ] = property_index++;
    PropertyIndexMap[ "scroll-snap-points-x:" ] = property_index++;
    PropertyIndexMap[ "user-select:" ] = property_index++;
    PropertyIndexMap[ "pointer-events:" ] = property_index++;
    PropertyIndexMap[ "cursor:" ] = property_index++;
    PropertyIndexMap[ "transition:" ] = property_index++;
    PropertyIndexMap[ "transition-property:" ] = property_index++;
    PropertyIndexMap[ "transition-delay:" ] = property_index++;
    PropertyIndexMap[ "transition-duration:" ] = property_index++;
    PropertyIndexMap[ "transition-timing-function:" ] = property_index++;
    PropertyIndexMap[ "animation:" ] = property_index++;
    PropertyIndexMap[ "animation-name:" ] = property_index++;
    PropertyIndexMap[ "animation-delay:" ] = property_index++;
    PropertyIndexMap[ "animation-duration:" ] = property_index++;
    PropertyIndexMap[ "animation-timing-function:" ] = property_index++;
    PropertyIndexMap[ "animation-iteration-count:" ] = property_index++;
    PropertyIndexMap[ "animation-direction:" ] = property_index++;
    PropertyIndexMap[ "animation-fill-mode:" ] = property_index++;
    PropertyIndexMap[ "animation-play-state:" ] = property_index++;
}

// ~~

string GetProperty(
    string line
    )
{
    long
        colon_character_index;
    string
        trimmed_line;

    trimmed_line = line.strip();
    colon_character_index = trimmed_line.indexOf( ':' );

    if ( colon_character_index > 0 )
    {
        return trimmed_line[ 0 .. colon_character_index + 1 ];
    }
    else
    {
        return "";
    }
}

// ~~

long GetPropertyIndex(
    string line
    )
{
    long
        property_index;
    string
        property;

    property = GetProperty( line );

    if ( ( property in PropertyIndexMap ) !is null )
    {
        return PropertyIndexMap[ property ];
    }
    else
    {
        return 0;
    }
}

// ~~

long GetCategoryIndex(
    long property_index
    )
{
    return property_index >> 6;
}

// ~~

bool HasTags(
    string file_text
    )
{
    return file_text.stripLeft().startsWith( "<" );
}

// ~~

bool IsOpeningTag(
    string line
    )
{
    return line.stripLeft().startsWith( "<style" );
}

// ~~

bool IsClosingTag(
    string line
    )
{
    return line.strip() == "</style>";
}

// ~~

bool IsOpeningBrace(
    string line
    )
{
    return line.strip() == "{";
}

// ~~

bool IsClosingBrace(
    string line
    )
{
    return line.strip() == "}";
}

// ~~

bool IsExtend(
    string line
    )
{
    return line.stripLeft().startsWith( "@extend " );
}

// ~~

bool IsMedia(
    string line
    )
{
    string
        trimmed_line;

    trimmed_line = line.stripLeft();

    return
        trimmed_line.toLower().startsWith( "+media(" )
        || trimmed_line.startsWith( "@media " );
}

// ~~

string[] GetLineArray(
    string text
    )
{
    return text.replace( "\r", "" ).replace( "\t", "    " ).split( '\n' );
}

// ~~

void RemoveEmptyLines(
    ref string[] line_array
    )
{
    long
        line_index;

    line_array = line_array.join( '\n' ).split( '\n' );

    for ( line_index = 0;
          line_index < line_array.length;
          ++line_index )
    {
        line_array[ line_index ] = line_array[ line_index ].stripRight();
    }

    while ( line_array.length > 0
            && line_array[ 0 ] == "" )
    {
        line_array = line_array[ 1 .. $ ];
    }

    while ( line_array.length > 0
            && line_array[ $ - 1 ] == "" )
    {
        line_array = line_array[ 0 .. $ - 1 ];
    }

    for ( line_index = 0;
          line_index + 1 < line_array.length;
          ++line_index )
    {
        if ( line_array[ line_index ] == ""
             && ( line_array[ line_index + 1 ] == ""
                  || line_array[ line_index + 1 ].IsClosingBrace() ) )
        {
            line_array = line_array[ 0 .. line_index ] ~ line_array[ line_index + 1 .. $ ];

            --line_index;
        }
        else if ( line_array[ line_index ].IsOpeningBrace()
                  && line_array[ line_index + 1 ] == "" )
        {
            line_array = line_array[ 0 .. line_index + 1 ] ~ line_array[ line_index + 2 .. $ ];

            --line_index;
        }
    }
}

// ~~

void EmbedMedia(
    ref string[] line_array,
    bool file_has_tags
    )
{
    bool
        line_array_has_changed;
    long
        line_index,
        media_line_index,
        media_rule_first_line_index,
        media_rule_last_line_index,
        rule_last_line_index,
        style_line_index;
    long[ string ]
        rule_last_line_index_map;
    string
        indentation,
        media_query,
        media_rule_selector,
        rule_selector;
    string[]
        media_rule_line_array;

    line_array.RemoveEmptyLines();

    if ( file_has_tags )
    {
        indentation = "    ";
    }
    else
    {
        indentation = "";
    }

    do
    {
        line_array_has_changed = false;

        for ( style_line_index = 0;
              style_line_index < line_array.length
              && !line_array_has_changed;
              ++style_line_index )
        {
            if ( line_array[ style_line_index ].IsOpeningTag()
                 || !file_has_tags )
            {
                for ( media_line_index = style_line_index;
                      !line_array_has_changed
                      && media_line_index + 2 < line_array.length
                      && !line_array[ media_line_index ].IsClosingTag();
                      ++media_line_index )
                {
                    if ( line_array[ media_line_index ].toLower().startsWith( indentation ~ "+Media(" )
                         && line_array[ media_line_index + 1 ] == indentation ~ "{" )
                    {
                        media_query = line_array[ media_line_index ];

                        while ( media_line_index + 2 < line_array.length
                                && line_array[ media_line_index + 2 ] == "" )
                        {
                            line_array = line_array[ 0 .. media_line_index + 2 ] ~ line_array[ media_line_index + 3 .. $ ];
                            line_array_has_changed = true;
                        }

                        if ( line_array[ media_line_index + 2 ] == indentation ~ "}" )
                        {
                            line_array = line_array[ 0 .. media_line_index ] ~ line_array[ media_line_index + 3 .. $ ];
                            line_array_has_changed = true;
                        }
                        else
                        {
                            for ( media_rule_first_line_index = media_line_index + 2;
                                  !line_array_has_changed
                                  && media_rule_first_line_index + 1 < line_array.length
                                  && line_array[ media_rule_first_line_index ] != indentation ~ "}"
                                  && !line_array[ media_rule_first_line_index ].IsClosingTag();
                                  ++media_rule_first_line_index )
                            {
                                if ( !line_array[ media_rule_first_line_index - 1 ].startsWith( indentation ~ "    ." )
                                     && !line_array[ media_rule_first_line_index - 1 ].endsWith( "," )
                                     && line_array[ media_rule_first_line_index ].startsWith( indentation ~ "    ." )
                                     && line_array[ media_rule_first_line_index + 1 ] == indentation ~ "    {" )
                                {
                                    media_rule_selector = line_array[ media_rule_first_line_index ].strip();

                                    for ( media_rule_last_line_index = media_rule_first_line_index + 1;
                                          media_rule_last_line_index < line_array.length;
                                          ++media_rule_last_line_index )
                                    {
                                        if ( line_array[ media_rule_last_line_index ] == indentation ~ "    }" )
                                        {
                                            if ( ( media_rule_selector in rule_last_line_index_map ) !is null )
                                            {
                                                rule_last_line_index = rule_last_line_index_map[ media_rule_selector ];
                                                media_rule_line_array = "" ~ line_array[ media_rule_first_line_index .. media_rule_last_line_index + 1 ];
                                                media_rule_line_array[ 1 ] = "    " ~ media_query;

                                                line_array = line_array[ 0 .. media_rule_first_line_index ] ~ line_array[ media_rule_last_line_index + 1 .. $ ];

                                                line_array
                                                    = line_array[ 0 .. rule_last_line_index ]
                                                      ~ media_rule_line_array
                                                      ~ line_array[ rule_last_line_index .. $ ];

                                                line_array_has_changed = true;
                                            }

                                            break;
                                        }
                                    }
                                }
                            }
                        }
                    }
                    else if ( line_array[ media_line_index ].startsWith( indentation ~ "." ) )
                    {
                        rule_selector = line_array[ media_line_index ].strip();
                    }
                    else if ( line_array[ media_line_index ] == indentation ~ "}" )
                    {
                        if ( rule_selector != "" )
                        {
                            rule_last_line_index_map[ rule_selector ] = media_line_index;
                            rule_selector = "";
                        }
                    }
                }
            }
        }
    }
    while ( line_array_has_changed );
}

// ~~

void SortDeclarations(
    ref string[] line_array,
    bool file_has_tags
    )
{
    bool
        line_is_style,
        line_is_swapped;
    long
        line_index,
        line_property_index,
        next_line_property_index,
        pass_index;
    string
        line,
        next_line;

    line_array.RemoveEmptyLines();

    for ( pass_index = 0;
          pass_index < 3;
          ++pass_index )
    {
        line_is_style = !file_has_tags;
        line_is_swapped = false;

        for ( line_index = 0;
              line_index < line_array.length;
              ++line_index )
        {
            line = line_array[ line_index ];

            if ( file_has_tags
                 && line.IsOpeningTag() )
            {
                line_is_style = true;

                while ( line_index + 1 < line_array.length
                        && line_array[ line_index + 1 ] == "" )
                {
                    line_array = line_array[ 0 .. line_index + 1 ] ~ line_array[ line_index + 2 .. $ ];
                }
            }
            else if ( file_has_tags
                      && line.IsClosingTag() )
            {
                line_is_style = false;

                while ( line_index - 1 >= 0
                        && line_array[ line_index - 1 ] == "" )
                {
                    line_array = line_array[ 0 .. line_index - 1 ] ~ line_array[ line_index .. $ ];
                    --line_index;
                }
            }
            else if ( line_is_style )
            {
                line_property_index = line.GetPropertyIndex();

                if ( pass_index == 0 )
                {
                    if ( line_property_index != 0 )
                    {
                        while ( !line_array[ line_index ].endsWith( ";" )
                                && line_index + 1 < line_array.length
                                && line_array[ line_index + 1 ] != ""
                                && !line_array[ line_index + 1 ].IsClosingBrace() )
                        {
                            line_array[ line_index ] ~= "\n" ~ line_array[ line_index + 1 ];
                            line_array = line_array[ 0 .. line_index + 1 ] ~ line_array[ line_index + 2 .. $ ];
                        }

                        while ( line_index + 2 < line_array.length
                                && line_array[ line_index + 1 ] == ""
                                && ( line_array[ line_index + 2 ] == ""
                                     || line_array[ line_index + 2 ].GetIndentationSpaceCount()
                                        == line_array[ line_index ].GetIndentationSpaceCount() ) )
                        {
                            line_array = line_array[ 0 .. line_index + 1 ] ~ line_array[ line_index + 2 .. $ ];
                        }
                    }
                }
                else if ( pass_index == 1 )
                {
                    if ( line_property_index != 0 )
                    {
                        if ( line_index + 1 < line_array.length )
                        {
                            next_line = line_array[ line_index + 1 ];
                            next_line_property_index = next_line.GetPropertyIndex();

                            if ( next_line_property_index != 0
                                 && next_line_property_index < line_property_index )
                            {
                                line_array[ line_index ] = next_line;
                                line_array[ line_index + 1 ] = line;
                                line_is_swapped = true;
                            }
                        }
                    }
                }
                else if ( pass_index == 2 )
                {
                    if ( line_index + 1 < line_array.length )
                    {
                        next_line = line_array[ line_index + 1 ];

                        if ( line.IsExtend() )
                        {
                            if ( next_line != ""
                                 && !next_line.IsExtend()
                                 && !next_line.IsClosingBrace() )
                            {
                                line_array[ line_index ] ~= "\n";
                            }
                        }
                        else if ( line_property_index != 0 )
                        {
                            next_line_property_index = next_line.GetPropertyIndex();

                            if ( next_line.IsMedia()
                                 || ( next_line_property_index != 0
                                      && GetCategoryIndex( next_line_property_index ) != GetCategoryIndex( line_property_index ) ) )
                            {
                                line_array[ line_index ] ~= "\n";
                            }
                        }
                    }
                }
            }
        }

        if ( line_is_swapped )
        {
            --pass_index;
        }
    }
}

// ~~

string GetRemSize(
    Captures!string pixel_size
    )
{
    double
        pixel_count;

    pixel_count = pixel_size[ 1 ][ 1 .. $ - 2 ].to!double();

    return ( " " ~ ( pixel_count / 16.0 ).to!string() ~ "rem" ).replace( ".0rem", "rem" );
}

// ~~

void ConvertUnits(
    ref string[] line_array,
    bool file_has_tags
    )
{
    bool
        line_is_style;
    long
        line_index,
        line_property_index;
    string
        line;

    line_array.RemoveEmptyLines();

    line_is_style = !file_has_tags;

    for ( line_index = 0;
          line_index < line_array.length;
          ++line_index )
    {
        line = line_array[ line_index ];

        if ( file_has_tags
             && line.IsOpeningTag() )
        {
            line_is_style = true;
        }
        else if ( file_has_tags
                  && line.IsClosingTag() )
        {
            line_is_style = false;
        }
        else if ( line_is_style )
        {
            line_property_index = line.GetPropertyIndex();

            if ( line_property_index != 0 )
            {
                while ( !line_array[ line_index ].endsWith( ";" )
                        && line_index + 1 < line_array.length
                        && line_array[ line_index + 1 ] != ""
                        && !line_array[ line_index + 1 ].IsClosingBrace() )
                {
                    line_array[ line_index ] ~= "\n" ~ line_array[ line_index + 1 ];
                    line_array = line_array[ 0 .. line_index + 1 ] ~ line_array[ line_index + 2 .. $ ];
                }

                line_array[ line_index ] = replaceAll!GetRemSize( line_array[ line_index ], regex( `( -?[0-9.]+px)` ) );
            }
        }
    }
}

// ~~

void ProcessFile(
    string file_path
    )
{
    bool
        file_has_tags;
    string
        file_text;
    string[]
        line_array;

    file_text = file_path.ReadText();
    file_has_tags = HasTags( file_text );

    line_array = file_text.GetLineArray();

    if ( NewlineOptionIsEnabled )
    {
        line_array.RemoveEmptyLines();
    }

    if ( MediaOptionIsEnabled )
    {
        line_array.EmbedMedia( file_has_tags );
    }

    if ( StyleOptionIsEnabled )
    {
        line_array.SortDeclarations( file_has_tags );
    }

    if ( UnitOptionIsEnabled )
    {
        line_array.ConvertUnits( file_has_tags );
    }

    file_path.WriteText( line_array.join( '\n' ) );
}

// ~~

void IncludeFilePaths(
    string file_path_filter
    )
{
    string
        file_name_filter,
        file_path,
        folder_path;
    SpanMode
        span_mode;

    SplitFilePathFilter( file_path_filter, folder_path, file_name_filter, span_mode );

    foreach ( folder_entry; dirEntries( folder_path, file_name_filter, span_mode ) )
    {
        if ( folder_entry.isFile )
        {
            ProcessFile( folder_entry.name.GetLogicalPath() );
        }
    }
}

// ~~

void main(
    string[] argument_array
    )
{
    string
        input_folder_path,
        option,
        output_folder_path;

    argument_array = argument_array[ 1 .. $ ];

    NewlineOptionIsEnabled = false;
    MediaOptionIsEnabled = false;
    StyleOptionIsEnabled = false;
    UnitOptionIsEnabled = false;

    MakePropertyIndexMap();

    while ( argument_array.length >= 1
            && argument_array[ 0 ].startsWith( "--" ) )
    {
        option = argument_array[ 0 ];

        argument_array = argument_array[ 1 .. $ ];

        if ( option == "--newline" )
        {
            NewlineOptionIsEnabled = true;
        }
        else if ( option == "--media" )
        {
            MediaOptionIsEnabled = true;
        }
        else if ( option == "--style" )
        {
            StyleOptionIsEnabled = true;
        }
        else if ( option == "--unit"
                  && argument_array.length >= 1 )
        {
            UnitOptionIsEnabled = true;
            MinimumPixelCount = argument_array[ 0 ].to!double;

            argument_array = argument_array[ 1 .. $ ];
        }
        else if ( option == "--include"
                  && argument_array.length >= 1 )
        {
            IncludeFilePaths( argument_array[ 0 ].GetLogicalPath() );

            argument_array = argument_array[ 1 .. $ ];
        }
        else
        {
            Abort( "Invalid option : " ~ option );
        }
    }

    if ( argument_array.length != 0 )
    {
        writeln( "Usage :" );
        writeln( "    phyx [options]" );
        writeln( "Options :" );
        writeln( "    --newline" );
        writeln( "    --media" );
        writeln( "    --style" );
        writeln( "    --unit <minimum pixel count>" );
        writeln( "Examples :" );
        writeln( "    phyx --newline --include \".//*.phx\"" );
        writeln( "    phyx --newline --media --style --unit --include \".//*.pht\" --include \".//*.styl\"" );

        PrintError( "Invalid arguments : " ~ argument_array.to!string() );
    }
}
