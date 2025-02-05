use std::error::Error;
use crate::config;

#[derive(Debug, Clone)]
pub struct DatabaseSettings {
    pub host: String,
    pub port: u16,
    pub user: String,
    pub password: String,
    pub database: String,
    pub ssl_mode: String,
}

#[derive(Debug, Clone)]
pub struct AppSettings {
    pub host: String,
    pub port: u16,
}

#[derive(Debug, Clone)]
pub struct AwsSettings {
    pub access_key_id: String,
    pub secret_access_key: String,
}

#[derive(Debug, Clone)]
pub struct MiddlewareSettings {
    pub timeout_seconds: u64,
    pub request_limit_per_hour: u16,
}

#[derive(Debug, Clone)]
pub struct RedisSettings {
    pub host: String,
    pub port: u16,
    pub password: String,
}

#[derive(Debug, Clone)]
pub struct Settings {
    pub database_settings: DatabaseSettings,
    pub app_setting: AppSettings,
    pub aws_settings: AwsSettings,
    pub middleware_settings: MiddlewareSettings,
    pub redis_settings: RedisSettings,
}

impl Settings {
    pub fn new() -> Result<Self, Box<dyn Error>> {
        config::env::load_env();
        let database_settings = Self::get_database_settings()?;
        let app_setting = Self::get_app_settings()?;
        let aws_settings = Self::get_aws_settings()?;
        let middleware_settings = Self::get_middleware_settings()?;
        let redis_settings = Self::get_redis_settings()?;

        Ok(Self {
            database_settings,
            app_setting,
            aws_settings,
            middleware_settings,
            redis_settings,
        })
    }

    fn get_database_settings() -> Result<DatabaseSettings, Box<dyn Error>> {
        let database_settings = DatabaseSettings {
            host: std::env::var("DB_HOST")?,
            port: std::env::var("DB_PORT")?.parse()?,
            database: std::env::var("DB_NAME")?,
            user: std::env::var("DB_USER")?,
            password: std::env::var("DB_PASSWORD")?,
            ssl_mode: std::env::var("DB_SSL_MODE")?,
        };
        Ok(database_settings)
    }
    
    fn get_app_settings() -> Result<AppSettings, Box<dyn Error>> {
        let app_settings = AppSettings {
            host: std::env::var("APP_HOST")?,
            port: std::env::var("APP_PORT")?.parse()?,
        };
        Ok(app_settings)
    }

    fn get_aws_settings() -> Result<AwsSettings, Box<dyn Error>> {
        let aws_settings = AwsSettings {
            access_key_id: std::env::var("AWS_ACCESS_KEY_ID")?,
            secret_access_key: std::env::var("AWS_SECRET_ACCESS_KEY")?,
        };
        Ok(aws_settings)
    }

    pub fn get_middleware_settings() -> Result<MiddlewareSettings, Box<dyn Error>> {
        let middleware_settings = MiddlewareSettings {
            timeout_seconds: std::env::var("TIMEOUT_SECONDS")?.parse()?,
            request_limit_per_hour: std::env::var("REQUEST_LIMIT_PER_HOUR")?.parse()?,
        };
        Ok(middleware_settings)
    }

    pub fn get_redis_settings() -> Result<RedisSettings, Box<dyn Error>> {
        let redis_settings = RedisSettings {
            host: std::env::var("REDIS_HOST")?,
            port: std::env::var("REDIS_PORT")?.parse()?,
            password: std::env::var("REDIS_PASSWORD")?,
        };
        Ok(redis_settings)
    }
}