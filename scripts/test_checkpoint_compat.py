"""Independent numerical checks for the original checkpoint's DCNv2 adapter."""
from pathlib import Path
import importlib.util
import math
import torch
from torch import nn

source = Path(__file__).resolve().parents[1] / 'Intelligent Detection System for Transmission Line Defects-server/ultralytics/nn/checkpoint_compat.py'
spec = importlib.util.spec_from_file_location('checkpoint_compat', source)
compat = importlib.util.module_from_spec(spec)
spec.loader.exec_module(compat)


def reference(x, weight, bias, offset, mask, groups, deform_groups, padding):
    # Scalar bilinear sampling and convolution, independent of torchvision.
    batch, channels, height, width = x.shape
    outputs, _, kh, kw = weight.shape
    oh, ow = height + 2 * padding - kh + 1, width + 2 * padding - kw + 1
    result = torch.zeros(batch, outputs, oh, ow)
    offset = offset.flatten(1)
    mask = mask.flatten(1)
    for b in range(batch):
        for out_c in range(outputs):
            group = out_c // (outputs // groups)
            for y in range(oh):
                for z in range(ow):
                    value = float(bias[out_c])
                    for relative_c in range(channels // groups):
                        c = group * (channels // groups) + relative_c
                        dg = c // (channels // deform_groups)
                        for ky in range(kh):
                            for kx in range(kw):
                                point = dg * kh * kw + ky * kw + kx
                                index = y * ow + z
                                sy = y - padding + ky + float(offset[b, (2 * point) * oh * ow + index])
                                sx = z - padding + kx + float(offset[b, (2 * point + 1) * oh * ow + index])
                                sampled = 0.0
                                for iy in [math.floor(sy), math.floor(sy) + 1]:
                                    for ix in [math.floor(sx), math.floor(sx) + 1]:
                                        if 0 <= iy < height and 0 <= ix < width:
                                            sampled += float(x[b, c, iy, ix]) * (1 - abs(sy - iy)) * (1 - abs(sx - ix))
                                value += sampled * float(mask[b, point * oh * ow + index]) * float(weight[out_c, relative_c, ky, kx])
                    result[b, out_c, y, z] = value
    return result


torch.manual_seed(42)
for groups, deform_groups, oversized in [(1, 1, False), (2, 2, False), (1, 2, True)]:
    layer = compat.ModulatedDeformConv2d()
    layer.weight = nn.Parameter(torch.randn(4, 4 // groups, 3, 3))
    layer.bias = nn.Parameter(torch.randn(4))
    layer.stride, layer.padding, layer.dilation = (1, 1), (1, 1), (1, 1)
    x = torch.randn(2, 4, 3, 4)
    h, w = (6, 8) if oversized else (3, 4)
    offset = torch.randn(2, deform_groups * 18, h, w) * 0.3
    mask = torch.rand(2, deform_groups * 9, h, w)
    expected = reference(x, layer.weight, layer.bias, offset, mask, groups, deform_groups, 1)
    actual = layer(x, offset, mask)
    torch.testing.assert_close(actual, expected, atol=5e-6, rtol=5e-6)
    print(f'DCNv2 numerical parity passed: groups={groups}, deform_groups={deform_groups}, oversized={oversized}')
sigmoid = compat.HSigmoid()
sigmoid.bias, sigmoid.divisor, sigmoid.min_value, sigmoid.max_value = 3, 6, 0, 1
torch.testing.assert_close(sigmoid(torch.tensor([-10., 0., 10.])), torch.tensor([0., .5, 1.]))
print('HSigmoid parity passed')
