import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { useDispatch } from 'react-redux';
import { addToCart } from '../../redux/cart/cartSlice';
import { productAPI } from '../../api/modules/product';

export default function ProductDetailPage() {
  const { productId } = useParams();
  const navigate = useNavigate();
  const dispatch = useDispatch();
  const [product, setProduct] = useState(null);
  const [quantity, setQuantity] = useState(1);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    fetchProduct();
  }, [productId]);

  const fetchProduct = async () => {
    setLoading(true);
    setError('');
    try {
      const data = await productAPI.getProductById(productId);
      setProduct(data);
    } catch (err) {
      setError(err.message || 'Failed to load product');
    } finally {
      setLoading(false);
    }
  };

  const handleAddToCart = () => {
    for (let i = 0; i < quantity; i++) {
      dispatch(addToCart(product));
    }
    navigate('/cart');
  };

  if (loading) {
    return (
      <div className="container mx-auto px-4 py-12 text-center">
        <p className="text-gray-600">Loading product...</p>
      </div>
    );
  }

  if (error || !product) {
    return (
      <div className="container mx-auto px-4 py-12">
        <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded mb-6">
          {error || 'Product not found'}
        </div>
        <button 
          onClick={() => navigate('/products')}
          className="text-blue-600 hover:text-blue-700 underline"
        >
          Back to products
        </button>
      </div>
    );
  }

  return (
    <div className="container mx-auto px-4 py-12">
      <button 
        onClick={() => navigate('/products')}
        className="text-blue-600 hover:text-blue-700 mb-6"
      >
        ← Back to Products
      </button>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
        <div className="bg-gray-100 rounded-lg h-96 flex items-center justify-center overflow-hidden">
          {product.imageUrl && (
            <img 
              src={product.imageUrl} 
              alt={product.name}
              className="w-full h-full object-cover"
            />
          )}
        </div>

        <div>
          <h1 className="text-4xl font-bold mb-4">{product.name}</h1>
          <p className="text-gray-600 text-lg mb-4">{product.description}</p>

          <div className="bg-blue-50 border border-blue-200 rounded p-4 mb-6">
            <p className="text-3xl font-bold text-blue-600">${product.price.toFixed(2)}</p>
          </div>

          <div className="space-y-4 mb-6">
            <div>
              <label className="block text-gray-700 font-medium mb-2">Quantity</label>
              <div className="flex items-center space-x-2">
                <button 
                  onClick={() => setQuantity(Math.max(1, quantity - 1))}
                  className="bg-gray-200 hover:bg-gray-300 px-3 py-1 rounded"
                >
                  -
                </button>
                <input 
                  type="number" 
                  value={quantity} 
                  onChange={(e) => setQuantity(Math.max(1, parseInt(e.target.value) || 1))}
                  className="w-16 px-3 py-1 border border-gray-300 rounded text-center"
                />
                <button 
                  onClick={() => setQuantity(quantity + 1)}
                  className="bg-gray-200 hover:bg-gray-300 px-3 py-1 rounded"
                >
                  +
                </button>
              </div>
            </div>

            <div>
              <p className="text-gray-700">
                Stock: <span className={product.stock > 0 ? 'text-green-600 font-medium' : 'text-red-600 font-medium'}>
                  {product.stock > 0 ? `${product.stock} available` : 'Out of Stock'}
                </span>
              </p>
            </div>
          </div>

          {product.stock > 0 ? (
            <button 
              onClick={handleAddToCart}
              className="w-full bg-blue-600 text-white py-3 rounded-lg font-semibold hover:bg-blue-700"
            >
              Add to Cart
            </button>
          ) : (
            <button className="w-full bg-gray-400 text-white py-3 rounded-lg font-semibold cursor-not-allowed">
              Out of Stock
            </button>
          )}

          <div className="mt-8 pt-8 border-t border-gray-200">
            <h3 className="text-xl font-semibold mb-4">Product Details</h3>
            <dl className="space-y-2">
              <div className="flex">
                <dt className="text-gray-600 w-32">SKU:</dt>
                <dd className="text-gray-900">{product.sku || 'N/A'}</dd>
              </div>
              <div className="flex">
                <dt className="text-gray-600 w-32">Category:</dt>
                <dd className="text-gray-900">{product.category || 'N/A'}</dd>
              </div>
            </dl>
          </div>
        </div>
      </div>
    </div>
  );
}
