{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}

module Hayoo.Templates where

import qualified Text.Hamlet as Hamlet (HtmlUrl, hamlet)
import qualified Text.Blaze.Html.Renderer.String as Blaze (renderHtml)
--import qualified Text.Blaze.Html as Blaze (Html)
import Data.Text.Lazy (Text)
import qualified Data.Text as TS
import qualified Data.Text.Lazy as T

import qualified Hayoo.Common as Api
import qualified Holumbus.Server.Client as Api

data Routes = Home | HayooJs | HayooCSS | Autocomplete | Examples | About

render :: Routes -> [(TS.Text, TS.Text)] -> TS.Text
render Home _ = "/"
render HayooJs _ = "/hayoo.js"
render HayooCSS _ = "/hayoo.css"
render Autocomplete _ = "/autocomplete"
render Examples _ = "/examples"
render About _ = "/about"

renderTitle :: Text -> Text
renderTitle query
    | T.null query = "Hayoo! Haskell API Search"
    | otherwise = query `T.append` " - Hayoo!"

--header :: Blaze.Html
header :: Text -> Hamlet.HtmlUrl Routes
header query = [Hamlet.hamlet|
  <head>
  
    <title>#{renderTitle query}
    <script src="//ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js">
    <script src="//ajax.googleapis.com/ajax/libs/jqueryui/1.10.3/jquery-ui.min.js">
    <link href="//code.jquery.com/ui/1.10.3/themes/smoothness/jquery-ui.css" rel="stylesheet">

    <script src="//netdna.bootstrapcdn.com/bootstrap/3.0.3/js/bootstrap.min.js">
    <link href="//netdna.bootstrapcdn.com/bootstrap/3.0.3/css/bootstrap.min.css" rel="stylesheet">
    
    <link href=@{HayooCSS} rel="stylesheet">
    <script src=@{HayooJs}>
    
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
|]

navigation :: Text -> Hamlet.HtmlUrl Routes
navigation query = [Hamlet.hamlet|
<div .navbar .navbar-default .navbar-static-top role="navigation">

    <div .navbar-header .navbar-left>
        <a href=@{Home}>
            <img .logo src="//holumbus.fh-wedel.de/hayoo/hayoo.png" alt="Hayoo! logo" >
        <button type="button" .navbar-toggle data-toggle="collapse" data-target="#hayoo-navbar-collapse">
            <span .sr-only>Toggle navigation
            <span .icon-bar>
            <span .icon-bar>
            <span .icon-bar>
       
    <div .navbar-collapse .collapse #hayoo-navbar-collapse>
        <ul .nav .navbar-nav .navbar-left>
            <li .active>
                <form .navbar-form .navbar-left action="." method="get" id="search" role="search">
                    <div .form-group>
                        <input .form-control placeholder="Search" name="query" #hayoo type="text" autocomplete="off" accesskey="1" value="#{query}">
                    <input .btn .btn-default #submit type="submit" value="Search">

        <ul .nav .navbar-nav .navbar-right>
            <li >
                <a href=@{Examples}>Examples
            <li>
                <a href=@{About}>About
|]


footer :: Hamlet.HtmlUrl Routes
footer = [Hamlet.hamlet|
<footer>

    <a href=@{Home}> Hayoo Frontend
    &copy; 2014 Sebastian Philipp
|]

body :: Text -> Hamlet.HtmlUrl Routes -> T.Text 
body query content = T.pack $ Blaze.renderHtml $ [Hamlet.hamlet|
$doctype 5
<html lang="en">
    ^{header query}
    <body>
        ^{navigation query}
        
        <div class="container">
            ^{content}
        
        ^{footer}
|] render

renderResultHeading :: Api.SearchResult -> Hamlet.HtmlUrl Routes
renderResultHeading (Api.SearchResult u _ _ n s _ _ Api.Function) = [Hamlet.hamlet|
<div .panel-heading>
    <a href=#{u}>
        #{n}
    :: #{s}
|]

renderResultHeading (Api.SearchResult u _ _ n s _ _ Api.Method) = [Hamlet.hamlet|
<div .panel-heading>
    <a href=#{u}>
        #{n}
    :: #{s}
    <span .label .label-default>
        Class Method
|]

renderResultHeading (Api.SearchResult u _ _ n _ _ _ t) = [Hamlet.hamlet|
<div .panel-heading>
    #{show t}
    <a href=#{u}>
        #{n}
|]

renderResult :: Api.SearchResult -> Hamlet.HtmlUrl Routes
renderResult result = [Hamlet.hamlet|
<div .panel .panel-default>
    ^{renderResultHeading result} 
    <div .panel-body>
        <p>
            #{Api.resultPackage result} - #{Api.resultModule result}
        <p .description .more>
            #{Api.resultDescription result}
|]

renderLimitedRestults :: Api.LimitedResult Api.SearchResult -> Hamlet.HtmlUrl Routes
renderLimitedRestults limitedRes = [Hamlet.hamlet|
<ul .list-group>
    $forall result <- Api.lrResult limitedRes
        <li .list-group-item>
            ^{renderResult result} 
|]

mainPage :: Hamlet.HtmlUrl Routes
mainPage = [Hamlet.hamlet|
<div .jumbotron>
  <h1>
      Welcome!
|]

about :: Hamlet.HtmlUrl Routes
about = [Hamlet.hamlet|
<div .page-header>
  <h1>
      About Hayoo!
|]

examples :: Hamlet.HtmlUrl Routes
examples = [Hamlet.hamlet|
<div .page-header>
  <h1>
      Example Search Queries

<div .panel .panel-default>
    <div .panel-heading>
        <h3 .panel-title>
            If you don't find what you searched for by just searching for the name, you can try to search for specific propterties by perfixing them
    <div .panel-body>
        <p>
            <a href="@{Home}?query=name%3AmapM">name:mapM
            searches for the function name mapM in all packages
        <p>
            <a href="@{Home}?query=package%3Abase">package:base
            searches for the base package.
        <p>
            <a href="@{Home}?query=signature%3Aa%20-%3E%20a">signature:a -&gt; a
            searches for all functions with this siganture in all packages.
        <p>
            <a href="@{Home}?query=module%3AControl.Exception">module:Control.Exception
            searches for a specific module in all packages.
<div .panel .panel-default>
    <div .panel-heading>
        <h3 .panel-title>
            It is also possible to combine search queries
    <div .panel-body>
        <p>
            <a href="@{Home}?query=package%3Abase%20mapM">package:base mapM
            searches for the function name mapM in the base package
        <p>
            <a href="@{Home}?query=mapM%20OR%20foldM">MapM or foldM
            searches will give a list of either MapM or foldM
        <p>
            <a href="@{Home}?query=map%20BUT%20package%3Abase">map BUT package:base
            searches for map except, except for package base
<div .panel .panel-default>
    <div .panel-heading>
        <h3 .panel-title>
            You can also modify search queries
    <div .panel-body>
        <p>
            <a href="@{Home}?query=%22Map%20each%20element%22">"Map each element"
            searches for the string "Map each element"
        <p>
            <a href="@{Home}?query=%21mapM">!mapM
            searches case sensitive for mapM
        <p>
            <a href="@{Home}?query=~maMpaybe">~maMpaybe
            is a fuzzy search and will show mapMaybe

|]
