defmodule SSD1306 do
  @moduledoc """
  Documentation for Ssd1306.
  """

  alias Circuits.I2C

  # Constants
  # 011110+sa0+rw - 0x3c or 0x3d
  @ssd1306_i2c_address 0x3C
  @ssd1306_setcontrast 0x81
  @ssd1306_displayallon_resume 0xA4
  # @ssd1306_displayallon 0xA5
  @ssd1306_normaldisplay 0xA6
  @ssd1306_invertdisplay 0xA7
  @ssd1306_displayoff 0xAE
  @ssd1306_displayon 0xAF
  @ssd1306_setdisplayoffset 0xD3
  @ssd1306_setcompins 0xDA
  @ssd1306_setvcomdetect 0xDB
  @ssd1306_setdisplayclockdiv 0xD5
  @ssd1306_setprecharge 0xD9
  @ssd1306_setmultiplex 0xA8
  # @ssd1306_setlowcolumn 0x00
  # @ssd1306_sethighcolumn 0x10
  @ssd1306_setstartline 0x40
  @ssd1306_memorymode 0x20
  @ssd1306_columnaddr 0x21
  @ssd1306_pageaddr 0x22
  # @ssd1306_comscaninc 0xC0
  @ssd1306_comscandec 0xC8
  @ssd1306_segremap 0xA0
  @ssd1306_chargepump 0x8D
  # @ssd1306_externalvcc 0x1
  # @ssd1306_switchcapvcc 0x2

  def command(i2c, data) do
    I2C.write!(i2c, @ssd1306_i2c_address, <<0x00, data>>)
  end

  def data(i2c, data) do
    I2C.write!(i2c, @ssd1306_i2c_address, <<0x40, data>>)
  end

  @spec init(I2C.bus()) :: :ok
  def init(i2c) do
    command(i2c, @ssd1306_displayoff)
    # 0xd5
    command(i2c, @ssd1306_setdisplayclockdiv)
    # the suggested ratio 0x80
    command(i2c, 0x80)
    # 0xa8
    command(i2c, @ssd1306_setmultiplex)
    command(i2c, 0x3F)
    # 0xd3
    command(i2c, @ssd1306_setdisplayoffset)
    # no offset
    command(i2c, 0x0)
    # line #0
    command(i2c, @ssd1306_setstartline + 0x0)
    # 0x8d
    command(i2c, @ssd1306_chargepump)
    # if self._vccstate == ssd1306_externalvcc:
    #      command(i2c, 0x10)
    # else:
    command(i2c, 0x14)
    # 0x20
    command(i2c, @ssd1306_memorymode)
    # 0x1 - vertical mode
    command(i2c, 0x01)
    command(i2c, @ssd1306_segremap + 0x1)
    command(i2c, @ssd1306_comscandec)
    # 0xda
    command(i2c, @ssd1306_setcompins)
    command(i2c, 0x12)
    # 0x81
    command(i2c, @ssd1306_setcontrast)
    # if self._vccstate == ssd1306_externalvcc:
    #      command(i2c, 0x9f)
    # else:
    command(i2c, 0xCF)
    # 0xd9
    command(i2c, @ssd1306_setprecharge)
    # if self._vccstate == ssd1306_externalvcc:
    #      command(i2c, 0x22)
    # else:
    command(i2c, 0xF1)
    # 0xdb
    command(i2c, @ssd1306_setvcomdetect)
    command(i2c, 0x40)
    # 0xa4
    command(i2c, @ssd1306_displayallon_resume)
    # 0xA6
    command(i2c, @ssd1306_normaldisplay)

    command(i2c, @ssd1306_displayon)

    pages = div(64, 8)

    I2C.write!(
      i2c,
      @ssd1306_i2c_address,
      <<0x00, @ssd1306_columnaddr, 0, 127, @ssd1306_pageaddr, 0, pages - 1>>
    )
  end

  @doc """
  Display an image

  The image should be 1bpp with the pixels ordered vertically like this:

  ```text
  |  |  |  |  |
  |  |  |  |  |
  |  |  |  |  |
  v  v  v  v  v
  ```

  The bits are displayed smallest to largest, so 0x01 is the first pixel, 0x02 is right
  below it and so on.

  Normally images are stored like this:

  ```text
  ---------->
  ---------->
  ---------->
  ---------->
  ```

  To transform, rotate clockwise 90 degrees and then flip horizontally.
  """
  def display(i2c, image) do
    I2C.write!(i2c, @ssd1306_i2c_address, [0x40, image])
  end

  def clear(i2c) do
    display(i2c, <<0::8192>>)
  end

  @doc """
  Invert the display
  """
  def invert(i2c, true), do: command(i2c, @ssd1306_invertdisplay)
  def invert(i2c, false), do: command(i2c, @ssd1306_normaldisplay)
end
