<?php

namespace App;

class Packer
{
    public int $maxLength = 255;

    public function pack(array $values): string
    {
        $out = '';
        for ($i = 0; $i < count($values); $i++) {
            $v = $values[$i] & 0xFF;
            $out .= chr($v);
            if ($i + 1 < count($values)) {
                $out .= chr(($values[$i + 1] >> 4) & 0x0F | ($v << 4) & 0xF0);
            }
        }

        return substr($out, 0, $this->maxLength);
    }
}
