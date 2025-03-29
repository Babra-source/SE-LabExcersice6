<?php
ob_start();
include '../db/config.php';  

// Enable error reporting for debugging
error_reporting(E_ALL);
ini_set('display_errors', 1);

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    // Collect and trim form data
    $fname = trim($_POST['firstname']);
    $lname = trim($_POST['lastname']);
    $email = trim($_POST['email']);
    $password = trim($_POST['password']);
    $confirm_password = trim($_POST['confirm_password']);

    // Validate required fields
    if (empty($fname) || empty($lname) || empty($email) || empty($password) || empty($confirm_password)) {
        die('Please fill in all required fields.');
    }

    // Check if passwords match
    if ($confirm_password !== $password) {
        die('Passwords do not match.');
    }

    // Check if the email is already registered
    $stmt = $conn->prepare('SELECT email FROM users WHERE email = ?');
    $stmt->bind_param('s', $email);
    $stmt->execute();
    $results = $stmt->get_result();

    if ($results->num_rows > 0) {
        echo '<script>alert("User already registered.");</script>';
        echo '<script>window.location.href = "../view/signup.html";</script>';
    } else {
        // Hash password before storing
        $hashed_password = password_hash($password, PASSWORD_BCRYPT);
        $role = 2;  // Default role for new users

        // Corrected SQL statement
        $sql = "INSERT INTO users (first_name, last_name, email, password_hash, user_type, registration_date) 
                VALUES (?, ?, ?, ?, ?, NOW())";

        $stmt = $conn->prepare($sql);
        $stmt->bind_param('ssssi', $fname, $lname, $email, $hashed_password, $role);

        if ($stmt->execute()) {
            $_SESSION['fname'] = $fname;
            header('Location: ../view/login.html');
            exit();
        } else {
            echo "Error: " . $stmt->error;  // Debugging statement
            header('Location: ../view/signup.html'); 
            exit();
        }
    }

    $stmt->close();
}

$conn->close();
?>
