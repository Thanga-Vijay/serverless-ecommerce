import { useNavigate } from 'react-router-dom';
import { useDispatch } from 'react-redux';
import { addToCart } from '../../redux/cart/cartSlice';

export default function ProductCard({ product }) {
  const navigate = useNavigate();
  const dispatch = useDispatch();

  const handleAddToCart = () => {
    dispatch(addToCart(product));
  };

  return (
    <div className="bg-white rounded-lg shadow hover:shadow-lg transition-shadow overflow-hidden">
      <div 
        className="h-48 bg-gray-200 cursor-pointer hover:opacity-90 transition-opacity overflow-hidden"
        onClick={() => navigate(`/products/${product.id}`)}
      >
        {product.imageUrl && (
          <img 
            src={product.imageUrl} 
            alt={product.name}
            className="w-full h-full object-cover"
          />
        )}
      </div>
      <div className="p-4">
        <h3 
          onClick={() => navigate(`/products/${product.id}`)}
          className="font-semibold text-gray-800 cursor-pointer hover:text-blue-600 line-clamp-2"
        >
          {product.name}
        </h3>
        <p className="text-gray-600 text-sm line-clamp-2 mt-1">{product.description}</p>
        <div className="flex justify-between items-center mt-4">
          <span className="text-lg font-bold text-gray-900">
            ${product.price.toFixed(2)}
          </span>
          {product.stock > 0 ? (
            <button
              onClick={handleAddToCart}
              className="bg-blue-600 text-white px-3 py-1 rounded text-sm hover:bg-blue-700"
            >
              Add to Cart
            </button>
          ) : (
            <span className="text-red-600 text-sm font-medium">Out of Stock</span>
          )}
        </div>
      </div>
    </div>
  );
}
