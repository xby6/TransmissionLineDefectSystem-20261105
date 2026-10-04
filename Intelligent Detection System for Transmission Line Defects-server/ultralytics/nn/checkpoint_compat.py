"""Load the two MMCV layers in the original checkpoint on CPU-only Windows.

All trained parameters are retained. Deformable convolution uses torchvision's
compiled DCNv2 operator; it is never replaced with an ordinary convolution.
"""
import pickle
import torch
from torch import nn
from torchvision.ops import deform_conv2d


class ModulatedDeformConv2d(nn.Module):
    def forward(self, x, offset, mask):
        # Original DyHead supplies the middle-level offsets even for the smaller
        # high-level feature. MMCV's bundled C++ operator reads a contiguous
        # prefix per batch using the convolution's computed output dimensions.
        # Preserve that memory interpretation rather than resizing the offsets.
        out_h = (x.shape[-2] + 2 * self.padding[0] - self.dilation[0] * (self.weight.shape[-2] - 1) - 1) // self.stride[0] + 1
        out_w = (x.shape[-1] + 2 * self.padding[1] - self.dilation[1] * (self.weight.shape[-1] - 1) - 1) // self.stride[1] + 1
        if offset.shape[-2:] != (out_h, out_w):
            offset = offset.flatten(1)[:, :offset.shape[1] * out_h * out_w].reshape(x.shape[0], offset.shape[1], out_h, out_w).contiguous()
            mask = mask.flatten(1)[:, :mask.shape[1] * out_h * out_w].reshape(x.shape[0], mask.shape[1], out_h, out_w).contiguous()
        return deform_conv2d(x, offset, self.weight, self.bias,
                             stride=self.stride, padding=self.padding,
                             dilation=self.dilation, mask=mask)


class HSigmoid(nn.Module):
    def forward(self, x):
        return ((x + self.bias) / self.divisor).clamp(self.min_value, self.max_value)


class Unpickler(pickle.Unpickler):
    def find_class(self, module, name):
        replacements = {
            ('mmcv.ops.modulated_deform_conv', 'ModulatedDeformConv2d'): ModulatedDeformConv2d,
            ('mmcv.cnn.bricks.hsigmoid', 'HSigmoid'): HSigmoid,
        }
        if (module, name) in replacements:
            try:
                return super().find_class(module, name)
            except (ImportError, OSError):
                return replacements[(module, name)]
        return super().find_class(module, name)


load = pickle.load
loads = pickle.loads
dump = pickle.dump
dumps = pickle.dumps
