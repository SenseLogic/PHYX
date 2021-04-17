![](https://github.com/senselogic/PHYX/blob/master/LOGO/phyx.png)

# Phyx

Phoenix style fixer.

## Description

Fixes style declarations according to [Coda](https://github.com/senselogic/CODA) rules.

## Sample

Old file :

```bash
.header-menu
{

    @extend menu;
    display: block;
    background:
        url( '/static/image/header_menu/first_background.png' ),
        url( '/static/image/header_menu/second_background.png' );
    padding: 0;
    margin: 0;
    border: 0;
    +Media( above-10em )
    {
        display: block;
        padding: 11px;
        margin: 11px;
        border: 11px;
    }

}

.header-menu-button
{
    @extend menu-button;
    display: block;
    background:
        url( '/static/image/header_menu/first_background.png' ),
        url( '/static/image/header_menu/second_background.png' );
    padding: 0;
    margin: 0;

    border: 0;
    +Media( above-10em )
    {
        display: block;
        padding: 12px;
        margin: 12px;
        border: 12px;
    }
}

+Media( above-20em )
{
    .header-menu
    {
        display: block;
        padding: 21px;
        margin: 21px;
        border: 21px;
    }

    .header-menu-button
    {
        display: block;
        padding: 22px;
        margin: 22px;
        border: 22px;
    }
}

+Media( above-30em )
{
    .header-menu
    {
        display: block;
        padding: 31px;
        margin: 31px;
        border: 31px;
    }

    .header-menu-button
    {
        display: block;
        padding: 32px;
        margin: 32px;
        border: 32px;
    }
}
```

New file :

```php
.header-menu
{
    @extend menu;

    margin: 0;
    border: 0;
    padding: 0;

    display: block;

    background:
        url( '/static/image/header_menu/first_background.png' ),
        url( '/static/image/header_menu/second_background.png' );

    +Media( above-10em )
    {
        margin: 11px;
        border: 11px;
        padding: 11px;

        display: block;
    }

    +Media( above-20em )
    {
        margin: 21px;
        border: 21px;
        padding: 21px;

        display: block;
    }

    +Media( above-30em )
    {
        margin: 31px;
        border: 31px;
        padding: 31px;

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
        url( '/static/image/header_menu/first_background.png' ),
        url( '/static/image/header_menu/second_background.png' );

    +Media( above-10em )
    {
        margin: 12px;
        border: 12px;
        padding: 12px;

        display: block;
    }

    +Media( above-20em )
    {
        margin: 22px;
        border: 22px;
        padding: 22px;

        display: block;
    }

    +Media( above-30em )
    {
        margin: 32px;
        border: 32px;
        padding: 32px;

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
phyx <file path filter> ...
```

### Example

```bash
phyx VIEW//*.pht STYLE/*.styl
```

Fixes the style declarations in the `.pht` files of the `VIEW/` folder and subfolders,
and in the `.styl` files of the `STYLE/` folder.

## Limitations

Media queries embedding requires Coda-compliant indentation.

## Version

0.1

## Author

Eric Pelzer (ecstatic.coder@gmail.com).

## License

This project is licensed under the GNU General Public License version 3.

See the [LICENSE.md](LICENSE.md) file for details.
