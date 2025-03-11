from django.shortcuts import render
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from io import BytesIO
import base64

# Create your views here.
def mandelbrot_view(request):
    # Define Mandelbrot parameters
    width, height = 1600, 1200
    x = np.linspace(-2, 0, width)
    y = np.linspace(0, 1.5, height)
    X, Y = np.meshgrid(x, y)
    C = X + 1j * Y
    Z = np.zeros_like(C, dtype=complex)
    mask = np.ones_like(C, dtype=bool)

    # Iterate to generate Mandelbrot set
    for _ in range(50):
        Z[mask] = Z[mask] * Z[mask] + C[mask]
        mask[np.abs(Z) > 2] = False

    # Plot using matplotlib
    plt.imshow(mask, extent=(-2, 1, -1.5, 1.5), cmap='hot')
    plt.axis('off')

    # Save to a BytesIO buffer and encode as base64
    buffer = BytesIO()
    plt.savefig(buffer, format='png', bbox_inches='tight', pad_inches=0)
    buffer.seek(0)
    image_png = buffer.getvalue()
    buffer.close()
    encoded_image = base64.b64encode(image_png).decode('utf-8')

    context = {
        'encoded_image': encoded_image
    }

    return render(request, 'mandelbrot/mandelbrot.html', context)