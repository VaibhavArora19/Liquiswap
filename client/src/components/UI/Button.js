const Button = (props) => {
    const classes = `btn ${props.classes}`;

    const clickHandler = () => {
        if(props.onClick){
            props.onClick();
        }
        return;
    }

    return <button className= {classes} onClick = {clickHandler}>{props.label}</button>
};

export default Button;