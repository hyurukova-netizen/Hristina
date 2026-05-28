#!/bin/bash
echo "🚀 Starting full-stack development environment..."

# Check if Docker is running
if ! docker ps &>/dev/null; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

# Build PHP image if needed
echo "📦 Building PHP Laravel image..."
docker compose build php_fpm

# Start all services
echo "🔄 Starting all services..."
docker compose up -d

# Wait for services to be ready
echo "⏳ Waiting for services to start..."
sleep 15

# Check if Laravel needs setup
if [ ! -f backend/.env ] || ! grep -q "APP_KEY=base64:" backend/.env; then
    echo "🔧 Setting up Laravel..."
    
    # Generate application key
    docker compose exec -T php_fpm php artisan key:generate --force || echo "⚠️  Key generation failed, continuing..."
    
    # Install composer dependencies if vendor doesn't exist
    if [ ! -d "backend/vendor" ]; then
        echo "📦 Installing Composer dependencies..."
        docker compose exec -T php_fpm composer install --no-interaction --prefer-dist --optimize-autoloader || echo "⚠️  Composer install failed, continuing..."
    fi
    
    # Run migrations
    echo "🗄️ Running database migrations..."
    docker compose exec -T php_fpm php artisan migrate --force || echo "⚠️  Migrations failed, continuing..."
    
    # Cache configurations
    docker compose exec -T php_fpm php artisan config:cache || echo "⚠️  Config cache failed, continuing..."
    docker compose exec -T php_fpm php artisan route:cache || echo "⚠️  Route cache failed, continuing..."
    
    # Set proper permissions
    docker compose exec -T php_fpm chown -R laravel:laravel /var/www/html/storage || echo "⚠️  Permission setup failed, continuing..."
    docker compose exec -T php_fpm chown -R laravel:laravel /var/www/html/bootstrap/cache || echo "⚠️  Permission setup failed, continuing..."
fi

echo "✅ Development environment started!"
echo ""
echo "📊 Service Status:"
docker compose ps

echo ""
echo "🌐 Access URLs:"
# Note: If URLs below show wrong ports, check actual ports with: docker compose ps
FRONTEND_PORT=$(grep "FRONTEND_PORT" docker-compose.yml | head -1 | sed 's/.*"\([0-9]*\):.*/\1/')
BACKEND_PORT=$(grep "BACKEND_PORT" docker-compose.yml | head -1 | sed 's/.*"\([0-9]*\):.*/\1/')

echo "  Frontend (Next.js): http://localhost:${FRONTEND_PORT:-8200}"
echo "  Backend (Laravel): http://localhost:${BACKEND_PORT:-8201}"
echo "  API Status: http://localhost:${BACKEND_PORT:-8201}/api/status"
echo ""
echo "💡 To verify actual ports, run: docker compose ps"
echo ""
echo "📋 Useful commands:"
echo "  docker compose logs -f          # View logs"
echo "  docker compose ps               # Check status"
echo "  docker compose down             # Stop services"
echo "  ./laravel-setup.sh              # Initialize Laravel fully"
