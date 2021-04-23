![](https://github.com/senselogic/PHYX/blob/master/LOGO/phyx.png)

# Phyx

Phoenix code fixer.

## Description

Fixes newlines and style declarations according to [Coda](https://github.com/senselogic/CODA) rules.

## Sample

### Before :

```bash
.header-menu
{

    @extend menu;
    display: block;
    background:
        url( '/static/image/header_menu/first_background.png' ) no-repeat center center / cover,
        url( '/static/image/header_menu/second_background.png' ) no-repeat center center / cover;
    font-size: 24px;
    padding: 0;
    margin: 0;
    border: 0;
    +Media( min-width-10em )
    {
        display: block;
        padding: 8px;
        margin: 8px 16px;
        border: 8px;
    }

}

.header-menu-button
{
    @extend menu-button;
    display: block;
    background:
        url( '/static/image/header_menu/first_background.png' ) no-repeat center center / cover,
        url( '/static/image/header_menu/second_background.png' ) no-repeat center center / cover;
    font-size: 24px;
    padding: 0;
    margin: 0;

    border: 0;
    +Media( min-width-10em )
    {
        display: block;
        padding: 8px;
        margin: 8px 16px;
        border: 8px;
    }
}

+Media( min-width-20em )
{
    .header-menu
    {
        display: block;
        padding: 16px;
        margin: 16px;
        border: 16px;
    }

    .header-menu-button
    {
        display: block;
        padding: 16px;
        margin: 16px;
        border: 16px;
    }
}

+Media( min-width-30em )
{
    .header-menu
    {
        display: block;
        padding: 24px;
        margin: 24px;
        border: 24px;
    }

    .header-menu-button
    {
        display: block;
        padding: 24px;
        margin: 24px;
        border: 24px;
    }
}
```

### After :

```bash
.header-menu
{
    @extend menu;

    margin: 0;
    border: 0;
    padding: 0;

    display: block;

    background:
        url( '/static/image/header_menu/first_background.png' ) no-repeat center center / cover,
        url( '/static/image/header_menu/second_background.png' ) no-repeat center center / cover;

    font-size: 1.5rem;

    +Media( min-width-10em )
    {
        margin: 0.5rem 1rem;
        border: 0.5rem;
        padding: 0.5rem;

        display: block;
    }

    +Media( min-width-20em )
    {
        margin: 1rem;
        border: 1rem;
        padding: 1rem;

        display: block;
    }

    +Media( min-width-30em )
    {
        margin: 1.5rem;
        border: 1.5rem;
        padding: 1.5rem;

        display: block;
    }
}

.header-menu-button
{
    @extend menu-button;

    margin: 0;
    border: 0;
    padding: 0;

    display: block;

    background:
        url( '/static/image/header_menu/first_background.png' ) no-repeat center center / cover,
        url( '/static/image/header_menu/second_background.png' ) no-repeat center center / cover;

    font-size: 1.5rem;

    +Media( min-width-10em )
    {
        margin: 0.5rem 1rem;
        border: 0.5rem;
        padding: 0.5rem;

        display: block;
    }

    +Media( min-width-20em )
    {
        margin: 1rem;
        border: 1rem;
        padding: 1rem;

        display: block;
    }

    +Media( min-width-30em )
    {
        margin: 1.5rem;
        border: 1.5rem;
        padding: 1.5rem;

        display: block;
    }
}
```

## Installation

Install the [DMD 2 compiler](https://dlang.org/download.html) (using the MinGW setup option on Windows).

Build the executable with the following command line :

```bash
dmd -m64 phyx.d
```

## Command line

```
phyx [options]
```

## Options

```
--newline : fix newlines
--media : fix media queries
--style : fix style declarations
--unit <minimum pixel count> : fix pixel units
```

### Example

```bash
phyx --newline --include ".//*.phx"
```

Fixes newlines in `.phx` files of the current folder and its subfolders.

```bash
phyx --newline --media --style --unit --include ".//*.pht" --include ".//*.styl"
```

Fixes newlines, media queries, style declarations and pixel units in `.pht` and `.styl` files of the current folder and its subfolders.

## Limitations

Media queries embedding requires Coda-compliant indentation.

## Version

0.1

## Author

Eric Pelzer (ecstatic.coder@gmail.com).

## License

This project is licensed under the GNU General Public License version 3.

See the [LICENSE.md](LICENSE.md) file for details.
