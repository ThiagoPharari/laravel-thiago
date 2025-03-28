FROM php:8.2-cli

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    unzip \
    git \
    curl \
    libpq-dev \
    libonig-dev \
    && docker-php-ext-install pdo pdo_pgsql mbstring

# Instalar Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Configurar directorios
WORKDIR /var/www/html
COPY . /var/www/html

# Configurar permisos
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Instalar dependencias de Laravel
RUN composer install --no-dev --optimize-autoloader

# Configurar variables de entorno
ARG APP_ENV=production
ENV APP_ENV=${APP_ENV}

# Exponer puerto usado por Artisan
EXPOSE 80

# Comando de inicio con php artisan serve
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=80"]
