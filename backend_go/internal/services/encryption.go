package services

import (
	"crypto/aes"
	"crypto/cipher"
	"crypto/rand"
	"encoding/base64"
	"encoding/binary"
	"fmt"
	"github.com/agungknwn/ngirit_backend/internal/models"
	"io"
	"log"
	"math"
	"os"
)

var encryptionKey []byte

func InitEncryption() error {
	key := os.Getenv("ENCRYPTION_KEY")
	log.Printf("ENCRYPTION_KEY length: %d chars", len(key)) // ADD THIS
	var err error
	encryptionKey, err = base64.StdEncoding.DecodeString(key)
	if err != nil || len(encryptionKey) != 32 {
		return fmt.Errorf("ENCRYPTION_KEY must be 32 bytes, got %d", len(encryptionKey))
	}
	return nil
}

// func init() {
// 	key := os.Getenv("ENCRYPTION_KEY")
// 	var err error
// 	encryptionKey, err = base64.StdEncoding.DecodeString(key)
// 	if err != nil || len(encryptionKey) != 32 {
// 		panic(fmt.Sprintf("ENCRYPTION_KEY must be 32 bytes, got %d (key: %q)", len(encryptionKey), key))
// 	}
// }

func Encrypt(plaintext string) (string, error) {
	block, err := aes.NewCipher(encryptionKey)
	if err != nil {
		return "", err
	}

	gcm, err := cipher.NewGCM(block)
	if err != nil {
		return "", err
	}

	nonce := make([]byte, gcm.NonceSize())
	if _, err := io.ReadFull(rand.Reader, nonce); err != nil {
		return "", err
	}

	ciphertext := gcm.Seal(nonce, nonce, []byte(plaintext), nil)
	return base64.StdEncoding.EncodeToString(ciphertext), nil
}

func Decrypt(encoded string) (string, error) {
	data, err := base64.StdEncoding.DecodeString(encoded)
	if err != nil {
		return "", err
	}

	block, err := aes.NewCipher(encryptionKey)
	if err != nil {
		return "", err
	}

	gcm, err := cipher.NewGCM(block)
	if err != nil {
		return "", err
	}

	nonceSize := gcm.NonceSize()
	if len(data) < nonceSize {
		return "", fmt.Errorf("ciphertext too short")
	}

	nonce, ciphertext := data[:nonceSize], data[nonceSize:]
	plaintext, err := gcm.Open(nil, nonce, ciphertext, nil)
	if err != nil {
		return "", err
	}

	return string(plaintext), nil
}

// EncryptFloat64 converts float64 → string → encrypts
func EncryptFloat64(value float64) (string, error) {
	buf := make([]byte, 8)
	binary.LittleEndian.PutUint64(buf, math.Float64bits(value))
	return Encrypt(base64.StdEncoding.EncodeToString(buf))
}

// DecryptFloat64 decrypts → string → float64
func DecryptFloat64(encoded string) (float64, error) {
	str, err := Decrypt(encoded)
	if err != nil {
		return 0, err
	}
	buf, err := base64.StdEncoding.DecodeString(str)
	if err != nil {
		return 0, err
	}
	return math.Float64frombits(binary.LittleEndian.Uint64(buf)), nil
}

func EncryptExpenseFields(e *models.Expense) error {
	encName, err := Encrypt(e.Name)
	if err != nil {
		return fmt.Errorf("encrypting name: %w", err)
	}
	e.EncryptedName = encName

	encAmount, err := EncryptFloat64(e.Amount)
	if err != nil {
		return fmt.Errorf("encrypting amount: %w", err)
	}
	e.EncryptedAmount = encAmount
	return nil
}

func DecryptExpenseFields(e *models.Expense) error {
	name, err := Decrypt(e.EncryptedName)
	if err != nil {
		return fmt.Errorf("decrypting name: %w", err)
	}
	e.Name = name

	amount, err := DecryptFloat64(e.EncryptedAmount)
	if err != nil {
		return fmt.Errorf("decrypting amount: %w", err)
	}
	e.Amount = amount
	return nil
}
