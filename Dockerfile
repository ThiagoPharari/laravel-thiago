FROM php:8.2-fpm

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    supervisor \
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

# Copiar configuración de Supervisor
COPY .docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Configurar variables de entorno (usar archivo .env en el contenedor)
ARG APP_ENV=production
ENV APP_ENV=${APP_ENV}

# Exponer puertos
EXPOSE 9000

# Comando de inicio
CMD ["php-fpm"]
