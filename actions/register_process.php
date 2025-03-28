<?php

ob_start();
include '../db/config';  

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

    // Check password match
    if ($confirm_password != $password) {
        die('Passwords do not match.');
    }

    // Check if the email is already registered
    $stmt = $conn->prepare('SELECT email FROM group_users WHERE email = ?');
    $stmt->bind_param('s', $email);
    $stmt->execute();
    $results = $stmt->get_result();

    if ($results->num_rows > 0) {
        echo '<script>alert("User already registered.");</script>';
        echo '<script>window.location.href = "../view/signup.html";</script>';
    } else {
        // Hash password before storing
        $hashed_password = password_hash($password, PASSWORD_BCRYPT);

        // Insert new user into the database
        $sql = "INSERT INTO group_users (fname, lname, email, password, role, created_at, updated_at) VALUES (?, ?, ?, ?, ?, NOW(), NOW())";
        $stmt = $conn->prepare($sql);
        $role = 2;  // Default role for new users
        $stmt->bind_param('ssssi', $fname, $lname, $email, $hashed_password, $role);

        if ($stmt->execute()) {
            $_SESSION['fname'] = $fname;
            header('Location: ../view/login.html');
        } else {
            header('Location: ../view/signup.html'); 
        }
    }

    $stmt->close();
}

$conn->close();

?>
